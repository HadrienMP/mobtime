port module Main exposing (..)

import Browser
import Browser.Navigation as Nav
import Other.Clock as Clock
import Graphics.Circle as Circle
import Html exposing (Html, a, audio, button, div, header, i, nav, p, section, span, text)
import Html.Attributes exposing (class, classList, href, id, src)
import Html.Events exposing (onClick)
import Json.Encode
import Lib.Ratio as Ratio exposing (Ratio)
import Settings.Dev
import Settings.Mobbers
import Sound.SoundSettings
import Settings.TimerSettings
import Sound.Sound as Sound
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


timerTab : Tab
timerTab =
    Tab Timer "/timer" "Timer" "fa-clock"


tabs : List Tab
tabs =
    [ timerTab
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
            SoundMsg Sound.Stop



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
    , timerSettings : Settings.TimerSettings.Model
    , dev : Settings.Dev.Model
    , mobbers : Settings.Mobbers.Model
    , soundSettings: Sound.SoundSettings.Model
    , mobClock : Clock.State
    , audio : Sound.Model
    }


init : String -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init _ url key =
    ( { key = key
      , url = url
      , tab = pageFrom url |> Maybe.withDefault timerTab
      , timerSettings = Settings.TimerSettings.init
      , dev = Settings.Dev.init
      , mobbers = Settings.Mobbers.init
      , soundSettings = Sound.SoundSettings.init
      , mobClock = Clock.Off
      , audio = Sound.init
      }
    , Cmd.none
    )


pageFrom : Url.Url -> Maybe Tab
pageFrom url =
    tabs
        |> List.filter (\p -> p.url == url.path)
        |> List.head



-- UPDATE


type Msg
    = LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url

    -- Timer messages
    | TimePassed Time.Posix
    | StartRequest
    | StopRequest

    | SoundMsg Sound.Msg

    -- Settings messages
    | TimerSettingsMsg Settings.TimerSettings.Msg
    | SoundSettingMsg Sound.SoundSettings.Msg
    | DevSettingsMsg Settings.Dev.Msg
    | MobbersSettingsMsg Settings.Mobbers.Msg


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
            ( { model | url = url, tab = pageFrom url |> Maybe.withDefault timerTab }
            , Cmd.none
            )

        TimePassed _ ->
            case model.mobClock of
                Clock.On turn ->
                    if turn.timeLeft <= 1 then
                        let
                            soundUpdate = Sound.turnEnded model.audio
                        in
                        ( { model
                            | mobClock = Clock.Off
                            , audio = Tuple.first soundUpdate
                            , mobbers = Tuple.first <| Settings.Mobbers.update Settings.Mobbers.TurnOver model.mobbers
                          }
                        , Tuple.second soundUpdate
                        )

                    else
                        ( { model | mobClock = Clock.On { turn | timeLeft = turn.timeLeft - Settings.Dev.seconds model.dev } }
                        , Cmd.none
                        )

                Clock.Off ->
                    ( model, Cmd.none )

        StartRequest ->
            ( { model | mobClock = Clock.On { timeLeft = model.timerSettings.turnLength * 60, length = model.timerSettings.turnLength } }
            , Sound.pick model.soundSettings.profile |> Cmd.map SoundMsg
            )

        StopRequest ->
            ( { model | mobClock = Clock.Off }
            , Cmd.none
            )

        SoundMsg soundMsg ->
            Sound.update model.audio soundMsg
            |> Tuple.mapBoth
                (\updated -> {model | audio = updated})
                (Cmd.map SoundMsg)


        MobbersSettingsMsg mobberMsg ->
            Settings.Mobbers.update mobberMsg model.mobbers
                |> Tuple.mapBoth (\it -> { model | mobbers = it }) (Cmd.map MobbersSettingsMsg)


        TimerSettingsMsg timerMsg ->
            Settings.TimerSettings.update timerMsg model.timerSettings
                |> Tuple.mapBoth
                    (\it -> { model | timerSettings = it })
                    (Cmd.map TimerSettingsMsg)

        SoundSettingMsg soundMsg ->
            Sound.SoundSettings.update soundMsg model.soundSettings soundCommands
                |> Tuple.mapBoth
                    (\it -> { model | soundSettings = it })
                    (Cmd.map SoundSettingMsg)

        DevSettingsMsg devMsg ->
            Settings.Dev.update devMsg model.dev
                |> Tuple.mapBoth (\dev -> { model | dev = dev }) (Cmd.map DevSettingsMsg)



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ Time.every 1000 TimePassed
        , Sound.subscriptions |> Sub.map SoundMsg
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
                    Settings.TimerSettings.view model.timerSettings
                        |> Html.map TimerSettingsMsg

                Mobbers ->
                    Settings.Mobbers.view model.mobbers
                        |> Html.map MobbersSettingsMsg

                SoundTab ->
                    Sound.SoundSettings.view model.soundSettings
                        |> Html.map SoundSettingMsg

                DevTab ->
                    Settings.Dev.view model.dev
                        |> Html.map DevSettingsMsg
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
                    ++ Clock.view mobCircle model.mobClock
                )
            , button
                [ onClick <| actionMessage <| actionOf model
                , class <| turnToString model.mobClock
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
        tabs


activeClass : Url.Url -> String -> ( String, Bool )
activeClass current tabUrl =
    ( "active", current.path == tabUrl )


turnToString : Clock.State -> String
turnToString turn =
    case turn of
        Clock.On _ ->
            "on"

        Clock.Off ->
            "off"


timeLeft : Model -> String
timeLeft model =
    case model.mobClock of
        Clock.On t ->
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
            if model.timerSettings.displaySeconds || t.timeLeft < 60 then
                minutesText ++ secondsText

            else
                (String.fromInt <| ceiling floatMinutes) ++ " min"

        Clock.Off ->
            ""


actionOf : Model -> Action
actionOf model =
    case ( model.mobClock, model.audio.state ) of
        ( Clock.On _, Sound.NotPlaying ) ->
            Stop

        ( Clock.On _, Sound.Playing ) ->
            StopSound

        ( Clock.Off, Sound.Playing ) ->
            StopSound

        ( Clock.Off, Sound.NotPlaying ) ->
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

