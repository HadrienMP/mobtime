port module Main exposing (..)

import Browser
import Browser.Navigation as Nav
import Circle
import Html exposing (Html, a, audio, button, div, header, i, nav, p, section, span, text)
import Html.Attributes exposing (class, classList, href, id, src)
import Html.Events exposing (onClick)
import Json.Encode
import Random
import Ratio exposing (Ratio)
import Settings.Dev
import Settings.Mobbers
import Settings.Sound
import Settings.Timer
import Sounds
import Svg exposing (Svg, svg)
import Svg.Attributes as Svg
import Time
import Timer
import Url



-- MAIN


main : Program String Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlChange = UrlChanged
        , onUrlRequest = LinkClicked
        }


port store : Json.Encode.Value -> Cmd msg


port soundCommands : Json.Encode.Value -> Cmd msg


port soundEnded : (String -> msg) -> Sub msg



-- MODEL


type TabType
    = Timer
    | Mobbers
    | SoundTab
    | DevTab


type alias Tab =
    { type_ : TabType
    , url : String
    , name : String
    , icon : String
    }


timerPage : Tab
timerPage =
    Tab Timer "/timer" "Timer" "fa-clock"


pages : List Tab
pages =
    [ timerPage
    , Tab Mobbers "/mobbers" "Mobbers" "fa-users"
    , Tab SoundTab "/audio" "Sound" "fa-volume-up"
    , Tab DevTab "/dev" "Dev" "fa-code"
    ]


type alias Audio =
    { state : SoundStatus
    , sound : Sounds.Sound
    }


type SoundStatus
    = Playing
    | NotPlaying


type alias Roles =
    List String


type alias Mobbers =
    List String


type alias MobberRole =
    { role : String
    , name : String
    }


type alias Model =
    { key : Nav.Key
    , url : Url.Url
    , tab : Tab
    , timerSettings : Settings.Timer.Model
    , dev : Settings.Dev.Model
    , mobbers : Settings.Mobbers.Model
    , soundSettings: Settings.Sound.Model
    , timer : Timer.Model
    }


init : String -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init _ url key =
    ( { key = key
      , url = url
      , tab = pageFrom url |> Maybe.withDefault timerPage
      , timerSettings = Settings.Timer.init
      , dev = Settings.Dev.init
      , mobbers = Settings.Mobbers.init
      , soundSettings = Settings.Sound.init
      , timer = Timer.init
      }
    , Cmd.none
    )


pageFrom : Url.Url -> Maybe Tab
pageFrom url =
    pages
        |> List.filter (\p -> p.url == url.path)
        |> List.head



-- UPDATE


type Msg
    = LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | TimePassed Time.Posix
    | PickedSound Sounds.Sound
    | SoundEnded String
    | TimerMsg Timer.Msg
    | TimerSettingsMsg Settings.Timer.Msg
    | SoundMsg Settings.Sound.Msg
    | DevMsg Settings.Dev.Msg
    | MobbersMsg Settings.Mobbers.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LinkClicked urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Nav.pushUrl model.key (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        UrlChanged url ->
            ( { model | url = url, tab = pageFrom url |> Maybe.withDefault timerPage }
            , Cmd.none
            )

        TimePassed currentTime ->
            case model.timer.turn of
                Timer.On turn ->
                    if turn.timeLeft <= 1 then
                        let
                            decision : (Timer.Model, Cmd Timer.Msg)
                            decision = Timer.turnOff model.timer soundCommands
                        in
                        ( { model
                            | timer = Tuple.first decision
                            , mobbers = Settings.Mobbers.rotate model.mobbers
                          }
                        , Tuple.second decision |> Cmd.map TimerMsg
                        )

                    else
                        ( { model | timer = Timer.timePassed model.timer model.dev.speed }
                        , Cmd.none
                        )

                Timer.Off ->
                    ( model, Cmd.none )

        StartRequest ->
            ( { model | turn = On { timeLeft = model.timerSettings.turnLength * 60, length = model.timerSettings.turnLength } }
            , Random.generate PickedSound <| Sounds.pick model.soundSettings.profile
            )

        StopRequest ->
            ( { model | turn = Off }
            , Cmd.none
            )

        PickedSound sound ->
            ( { model | audio = (\audio -> { audio | state = NotPlaying, sound = sound }) model.audio }
            , Cmd.none
            )

        SoundEnded _ ->
            ( { model | audio = (\audio -> { audio | state = NotPlaying }) model.audio }
            , Cmd.none
            )

        StopSoundRequest ->
            ( { model | audio = (\audio -> { audio | state = NotPlaying }) model.audio }
            , soundCommands stopCommand
            )

        MobbersMsg mobberMsg ->
            Settings.Mobbers.update mobberMsg model.mobbers
                |> Tuple.mapBoth (\it -> { model | mobbers = it }) (Cmd.map MobbersMsg)


        TimerSettingsMsg timerMsg ->
            Settings.Timer.update timerMsg model.timerSettings
                |> Tuple.mapBoth
                    (\it -> { model | timerSettings = it })
                    (Cmd.map TimerSettingsMsg)

        SoundMsg soundMsg ->
            Settings.Sound.update soundMsg model.soundSettings soundCommands
                |> Tuple.mapBoth
                    (\it -> { model | soundSettings = it })
                    (Cmd.map SoundMsg)

        DevMsg devMsg ->
            Settings.Dev.update devMsg model.dev
                |> Tuple.mapBoth (\dev -> { model | dev = dev }) (Cmd.map DevMsg)


playCommand : Json.Encode.Value
playCommand =
    Json.Encode.object
        [ ( "name", Json.Encode.string "play" )
        , ( "data", Json.Encode.object [] )
        ]


stopCommand : Json.Encode.Value
stopCommand =
    Json.Encode.object
        [ ( "name", Json.Encode.string "stop" )
        , ( "data", Json.Encode.object [] )
        ]



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ Time.every 1000 TimePassed
        , soundEnded SoundEnded
        ]



-- VIEW


view : Model -> Browser.Document Msg
view model =
    { title = (Timer.timeLeft model.timer model.timerSettings) ++ " | Mob Time !"
    , body =
        [ div
            [ id "container" ]
            [ headerView model
            , case model.tab.type_ of
                Timer ->
                    Settings.Timer.view model.timerSettings
                        |> Html.map TimerSettingsMsg

                Mobbers ->
                    Settings.Mobbers.view model.mobbers
                        |> Html.map MobbersMsg

                SoundTab ->
                    Settings.Sound.view model.soundSettings
                        |> Html.map SoundMsg

                DevTab ->
                    Settings.Dev.view model.dev
                        |> Html.map DevMsg
            ]
        ]
    }



-- ############################################################
-- HEADER
-- ############################################################


headerView : Model -> Html Msg
headerView model =
    let
        totalWidth =
            220

        outerRadiant =
            104

        pomodoroCircle =
            Circle.Circle
                outerRadiant
                (Circle.Coordinates (outerRadiant + 6) (outerRadiant + 6))
                (Circle.Stroke 10 "#999")

        mobCircle =
            Circle.inside pomodoroCircle <| Circle.Stroke 18 "#666"
    in
    header []
        [ Timer.view model.timer model.timerSettings |> Html.map TimerMsg
        , nav [] <| navLinks model.url
        ]


navLinks : Url.Url -> List (Html msg)
navLinks current =
    List.map
        (\page ->
            a
                [ href page.url, classList [ activeClass current page.url ] ]
                [ i [ class <| "fas " ++ page.icon ] [] ]
        )
        pages


activeClass : Url.Url -> String -> ( String, Bool )
activeClass current tabUrl =
    ( "active", current.path == tabUrl )
