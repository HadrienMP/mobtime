port module Main exposing (..)

import Action
import Browser
import Browser.Navigation as Nav
import Clock.Circle as Circle
import Clock.Main as Clock
import Clock.Settings
import Html exposing (Html, a, div, header, i, nav, p, section)
import Html.Attributes exposing (class, classList, href, id)
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
    , mobClock : Clock.Model
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
    | TimePassed Time.Posix
    | ClockMsg Clock.Msg
    | SoundMsg Sound.Msg
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
            Clock.timePassed model.mobClock model.dev
                |> handleClockResult model

        ClockMsg clockMsg ->
            Clock.update model.timerSettings clockMsg
                |> handleClockResult model

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


handleClockResult : Model -> Clock.UpdateResult -> ( Model, Cmd Msg )
handleClockResult model clockResult =
    let
        soundResult =
            Sound.handleClockEvents model.sound clockResult.event

        mobbersResult =
            Settings.Mobbers.handleClockEvents model.mobbers clockResult.event
    in
    ( { model
        | mobClock = clockResult.model
        , sound = soundResult.model
        , mobbers = mobbersResult.model
      }
    , Cmd.batch <|
        [ soundResult.command |> Cmd.map SoundMsg
        , clockResult.command |> Cmd.map ClockMsg
        , mobbersResult.command |> Cmd.map MobbersSettingsMsg
        ]
    )



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
                    , Action.actionView
                        { clock = model.mobClock, sound = model.sound, clockSettings = model.timerSettings }
                        { clock = ClockMsg, sound = SoundMsg }
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
    Clock.humanReadableTimeLeft model.mobClock model.timerSettings
        |> List.foldr (++) ""
        |> (\it ->
                if String.isEmpty it then
                    ""

                else
                    it ++ " | "
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
