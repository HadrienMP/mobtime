port module Main exposing (..)

import Browser
import Browser.Navigation as Nav
import Clock.Circle as Circle
import Clock.Main as Clock
import Clock.Settings
import Html exposing (Html, a, button, div, header, i, nav, p, section, span, text)
import Html.Attributes exposing (class, classList, href, id)
import Html.Events exposing (onClick)
import Json.Encode
import Lib.Ratio as Ratio exposing (Ratio)
import Settings.Dev
import Settings.Mobbers
import Sound.Main as Sound
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
    , timerSettings : Clock.Settings.Model
    , dev : Settings.Dev.Model
    , mobbers : Settings.Mobbers.Model
    , mobClock : Clock.State
    , sound : Sound.Model
    }


init : String -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init _ url key =
    ( { key = key
      , url = url
      , tab = pageFrom url |> Maybe.withDefault timerTab
      , timerSettings = Clock.Settings.init
      , dev = Settings.Dev.init
      , mobbers = Settings.Mobbers.init
      , mobClock = Clock.Off
      , sound = Sound.init
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
    | TimerSettingsMsg Clock.Settings.Msg
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
            let
                ( clock, clockEvent ) =
                    Clock.timePassed model.mobClock <| Settings.Dev.seconds model.dev
            in
            case clockEvent of
                Clock.Finished ->
                    let
                        ( sound, soundCmd ) =
                            Sound.turnEnded model.sound
                    in
                    ( { model
                        | mobClock = clock
                        , sound = sound
                        , mobbers = Settings.Mobbers.turnEnded model.mobbers
                      }
                    , soundCmd
                    )

                _ ->
                    ( { model | mobClock = clock }
                    , Cmd.none
                    )

        StartRequest ->
            ( { model | mobClock = Clock.start model.timerSettings.turnLength }
            , Sound.pick model.sound |> Cmd.map SoundMsg
            )

        StopRequest ->
            ( { model | mobClock = Clock.Off }
            , Cmd.none
            )

        SoundMsg soundMsg ->
            Sound.update model.sound soundMsg
                |> Tuple.mapBoth
                    (\updated -> { model | sound = updated })
                    (Cmd.map SoundMsg)

        MobbersSettingsMsg mobberMsg ->
            Settings.Mobbers.update mobberMsg model.mobbers
                |> Tuple.mapBoth (\it -> { model | mobbers = it }) (Cmd.map MobbersSettingsMsg)

        TimerSettingsMsg timerMsg ->
            Clock.Settings.update timerMsg model.timerSettings
                |> Tuple.mapBoth
                    (\it -> { model | timerSettings = it })
                    (Cmd.map TimerSettingsMsg)

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
    { title = pageTitle model
    , body =
        [ div
            [ id "container" ]
            [ header []
                [ section []
                    [ clockView model
                    , actionView model
                    ]
                ]
            , Sound.view model.sound |> Html.map SoundMsg
            , nav [] <| navLinks model.url
            , case model.tab.type_ of
                Timer ->
                    Clock.Settings.view model.timerSettings
                        |> Html.map TimerSettingsMsg

                Mobbers ->
                    Settings.Mobbers.view model.mobbers
                        |> Html.map MobbersSettingsMsg

                SoundTab ->
                    Sound.settingsView model.sound
                        |> Html.map SoundMsg

                DevTab ->
                    Settings.Dev.view model.dev
                        |> Html.map DevSettingsMsg
            ]
        ]
    }


pageTitle model =
    timeLeft model
        |> List.foldr (++) ""
        |> (\it ->
                if String.isEmpty it then
                    ""

                else
                    " | "
           )
        |> (\it -> it ++ "Mob Time !")



-- NAV


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



-- CLOCK


clockView : Model -> Html Msg
clockView model =
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
    svg
        [ Svg.width <| String.fromInt totalWidth
        , Svg.height <| String.fromInt totalWidth
        ]
        (Circle.drawWithoutInsideBorder pomodoroCircle Ratio.full
            ++ Clock.view mobCircle model.mobClock
        )


actionView : Model -> Html Msg
actionView model =
    button
        [ onClick <| actionMessage <| actionOf model
        , class <| turnToString model.mobClock
        ]
        [ span [ id "time-left" ] (timeLeft model |> List.map (\it -> span [] [ text it ]))
        , actionIcon <| actionOf model
        ]


turnToString : Clock.State -> String
turnToString turn =
    case turn of
        Clock.On _ ->
            "on"

        Clock.Off ->
            "off"


timeLeft : Model -> List String
timeLeft model =
    case model.mobClock of
        Clock.On turn ->
            Clock.Settings.format model.timerSettings turn.timeLeft

        Clock.Off ->
            []


actionOf : Model -> Action
actionOf model =
    case ( model.mobClock, model.sound.state ) of
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
