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
import SoundLibrary
import Svg exposing (Svg, svg)
import Svg.Attributes as Svg
import Time
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


type Action
    = Start
    | Stop
    | StopSound


actionMessage : Action -> Msg
actionMessage action =
    case action of
        Start ->
            StartRequest

        Stop ->
            StopRequest

        StopSound ->
            StopSoundRequest


type alias Audio =
    { state : SoundStatus
    , sound : SoundLibrary.Sound
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
    , timer : Settings.Timer.Model
    , dev : Settings.Dev.Model
    , mobbers : Settings.Mobbers.Model
    , sound: Settings.Sound.Model
    , turn : Turn
    , audio : Audio
    }


type Turn
    = Off
    | On { timeLeft : Int, length : Int }


init : String -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init _ url key =
    ( { key = key
      , url = url
      , tab = pageFrom url |> Maybe.withDefault timerPage
      , timer = Settings.Timer.init
      , dev = Settings.Dev.init
      , mobbers = Settings.Mobbers.init
      , sound = Settings.Sound.init
      , turn = Off
      , audio =
            { state = NotPlaying
            , sound = SoundLibrary.default
            }
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
    | StartRequest
    | StopRequest
    | PickedSound SoundLibrary.Sound
    | SoundEnded String
    | StopSoundRequest
    | TimerMsg Settings.Timer.Msg
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

        TimePassed _ ->
            case model.turn of
                On turn ->
                    if turn.timeLeft <= 1 then
                        ( { model
                            | turn = Off
                            , audio = (\audio -> { audio | state = Playing }) model.audio
                            , mobbers = Tuple.first <| Settings.Mobbers.update Settings.Mobbers.TurnOver model.mobbers
                          }
                        , soundCommands playCommand
                        )

                    else
                        ( { model | turn = On { turn | timeLeft = turn.timeLeft - Settings.Dev.seconds model.dev } }
                        , Cmd.none
                        )

                Off ->
                    ( model, Cmd.none )

        StartRequest ->
            ( { model | turn = On { timeLeft = model.timer.turnLength * 60, length = model.timer.turnLength } }
            , Random.generate PickedSound <| SoundLibrary.pick model.sound.profile
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


        TimerMsg timerMsg ->
            Settings.Timer.update timerMsg model.timer
                |> Tuple.mapBoth
                    (\it -> { model | timer = it })
                    (Cmd.map TimerMsg)

        SoundMsg soundMsg ->
            Settings.Sound.update soundMsg model.sound soundCommands
                |> Tuple.mapBoth
                    (\it -> { model | sound = it })
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


changeVolume : String -> Json.Encode.Value
changeVolume volume =
    Json.Encode.object
        [ ( "name", Json.Encode.string "volume" )
        , ( "data"
          , Json.Encode.object
                [ ( "volume", Json.Encode.string volume ) ]
          )
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
    { title = timeLeft model ++ " | Mob Time !"
    , body =
        [ div
            [ id "container" ]
            [ headerView model
            , case model.tab.type_ of
                Timer ->
                    Settings.Timer.view model.timer
                        |> Html.map TimerMsg

                Mobbers ->
                    Settings.Mobbers.view model.mobbers
                        |> Html.map MobbersMsg

                SoundTab ->
                    Settings.Sound.view model.sound
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
        [ section []
            [ svg
                [ Svg.width <| String.fromInt totalWidth
                , Svg.height <| String.fromInt totalWidth
                ]
                (Circle.drawWithoutInsideBorder pomodoroCircle Ratio.full
                    ++ Circle.draw mobCircle (ratio model)
                )
            , button
                [ onClick <| actionMessage <| actionOf model
                , class <| turnToString model.turn
                ]
                [ span [] [ text <| timeLeft model ]
                , actionIcon <| actionOf model
                ]
            ]
        , audio [ src <| "/sound/" ++ model.audio.sound ] []
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


turnToString : Turn -> String
turnToString turn =
    case turn of
        On _ ->
            "on"

        Off ->
            "off"


timeLeft : Model -> String
timeLeft model =
    case model.turn of
        On t ->
            let
                floatMinutes =
                    toFloat t.timeLeft / 60.0

                intMinutes =
                    floor floatMinutes

                secondsLeft =
                    t.timeLeft - (floor floatMinutes * 60)

                minutesText =
                    if intMinutes /= 0 then
                        String.fromInt intMinutes ++ " min "

                    else
                        ""

                secondsText =
                    if secondsLeft /= 0 then
                        String.fromInt secondsLeft ++ " " ++ "s"

                    else
                        ""
            in
            if model.timer.displaySeconds || t.timeLeft < 60 then
                minutesText ++ secondsText

            else
                (String.fromInt <| ceiling floatMinutes) ++ " min"

        Off ->
            ""


actionOf : Model -> Action
actionOf model =
    case ( model.turn, model.audio.state ) of
        ( On _, NotPlaying ) ->
            Stop

        ( On _, Playing ) ->
            StopSound

        ( Off, Playing ) ->
            StopSound

        ( Off, NotPlaying ) ->
            Start


actionIcon : Action -> Html msg
actionIcon action =
    case action of
        Start ->
            i [ class "fas fa-play" ] []

        Stop ->
            i [ class "fas fa-square" ] []

        StopSound ->
            i [ class "fas fa-volume-mute" ] []


ratio : Model -> Ratio
ratio model =
    case model.turn of
        On turn ->
            (1 - (toFloat (turn.timeLeft - 1) / (toFloat turn.length * 60)))
                |> Debug.log ""
                |> Ratio.from

        Off ->
            Ratio.full
