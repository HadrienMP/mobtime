port module Main exposing (..)

import Action
import Browser
import Clock.Circle as Circle
import Clock.Main as Clock
import Clock.Settings
import Html exposing (Html, div, header, section)
import Html.Attributes exposing (id)
import Json.Encode
import Lib.Ratio as Ratio exposing (Ratio)
import Settings.Dev
import Settings.Mobbers
import Sound.Main as Sound
import Svg exposing (Svg, svg)
import Svg.Attributes as Svg
import Tabs
import Time



-- MAIN


main : Program String Model Msg
main =
    Browser.document
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


port store : Json.Encode.Value -> Cmd msg



-- MODEL


type alias Model =
    { tab : Tabs.Tab
    , timerSettings : Clock.Settings.Model
    , dev : Settings.Dev.Model
    , mobbers : Settings.Mobbers.Model
    , mobClock : Clock.Model
    , sound : Sound.Model
    }


init : String -> ( Model, Cmd Msg )
init _ =
    ( { tab = Tabs.timerTab
      , timerSettings = Clock.Settings.init
      , dev = Settings.Dev.init
      , mobbers = Settings.Mobbers.init
      , mobClock = Clock.Off
      , sound = Sound.init
      }
    , Cmd.none
    )



-- UPDATE


type Msg
    = TimePassed Time.Posix
    | ClockMsg Clock.Msg
    | SoundMsg Sound.Msg
    | TimerSettingsMsg Clock.Settings.Msg
    | DevSettingsMsg Settings.Dev.Msg
    | MobbersSettingsMsg Settings.Mobbers.Msg
    | TabsMsg Tabs.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
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

        TabsMsg tabsMsg ->
            case tabsMsg of
                Tabs.Clicked tab ->
                    ( { model | tab = tab }, Cmd.none )


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
            , Tabs.navView model.tab |> Html.map TabsMsg
            , case model.tab.type_ of
                Tabs.Timer ->
                    Clock.Settings.view model.timerSettings
                        |> Html.map TimerSettingsMsg

                Tabs.Mobbers ->
                    Settings.Mobbers.view model.mobbers
                        |> Html.map MobbersSettingsMsg

                Tabs.SoundTab ->
                    Sound.settingsView model.sound
                        |> Html.map SoundMsg

                Tabs.DevTab ->
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
