module Mob.Main exposing (..)

import Html exposing (Html, div, h2, header, section)
import Html.Attributes exposing (class, id)
import Lib.BatchMsg
import Lib.Toast
import Mob.Action
import Mob.Clock.Circle as Circle
import Mob.Clock.Main as Clock
import Mob.Clock.Settings
import Mob.Pomodoro as Pomodoro
import Mob.Sound.Main as Sound
import Mob.Tabs.Mobbers
import Mob.Tabs.Share
import Mob.Tabs.Tabs
import Out.EventsMapping as EventsMapping exposing (EventsMapping)
import Svg exposing (Svg, svg)
import Svg.Attributes as Svg
import Time
import Url
import UserPreferences



-- MODEL


type alias Model =
    { name : String
    , tab : Mob.Tabs.Tabs.Tab
    , timerSettings : Mob.Clock.Settings.Model
    , mobbers : Mob.Tabs.Mobbers.Model
    , mobClock : Clock.Model
    , pomodoroClock : Pomodoro.Model
    , sound : Sound.Model
    }


init : String -> UserPreferences.Model -> Model
init name userPreferences =
    { name = name
    , tab = Mob.Tabs.Tabs.timerTab
    , timerSettings = Mob.Clock.Settings.init
    , mobbers = Mob.Tabs.Mobbers.init
    , mobClock = Clock.Off
    , pomodoroClock = Pomodoro.Ready
    , sound = Sound.init userPreferences.volume
    }



-- UPDATE


type Msg
    = TimePassed Time.Posix
    | MainClockMsg Clock.Msg
    | PomodoroClockMsg Pomodoro.Msg
    | SoundMsg Sound.Msg
    | TimerSettingsMsg Mob.Clock.Settings.Msg
    | MobbersSettingsMsg Mob.Tabs.Mobbers.Msg
    | TabsMsg Mob.Tabs.Tabs.Msg
    | ShareMsg Mob.Tabs.Share.Msg
    | Batch (List Msg)


type alias UpdateResult =
    { model : Model
    , command : Cmd Msg
    , toast : Lib.Toast.Toasts
    }


update : Msg -> Model -> UpdateResult
update msg model =
    case msg of
        TimePassed _ ->
            let
                pomodoroResult =
                    Pomodoro.timePassed model.pomodoroClock model.timerSettings

                ( clock, cmd ) =
                    Clock.timePassed model.mobClock model.timerSettings
                        |> handleClockResult model
                        |> Tuple.mapSecond Cmd.batch
            in
            UpdateResult { clock | pomodoroClock = pomodoroResult.model } cmd pomodoroResult.toasts

        MainClockMsg clockMsg ->
            Clock.update clockMsg model.mobClock model.timerSettings.turnLength
                |> handleClockResult model
                |> Tuple.mapSecond Cmd.batch
                |> (\( m, c ) -> UpdateResult m c [])

        PomodoroClockMsg clockMsg ->
            Pomodoro.update clockMsg model.pomodoroClock model.timerSettings.pomodoroLength
                |> Tuple.mapBoth
                    (\it -> { model | pomodoroClock = it })
                    (Cmd.map PomodoroClockMsg)
                |> (\( m, c ) -> UpdateResult m c [])

        SoundMsg soundMsg ->
            Sound.update model.sound soundMsg
                |> Tuple.mapBoth
                    (\updated -> { model | sound = updated })
                    (Cmd.map SoundMsg)
                |> (\( m, c ) -> UpdateResult m c [])

        MobbersSettingsMsg mobberMsg ->
            Mob.Tabs.Mobbers.update mobberMsg model.mobbers
                |> Tuple.mapBoth
                    (\it -> { model | mobbers = it })
                    (Cmd.map MobbersSettingsMsg)
                |> (\( m, c ) -> UpdateResult m c [])

        TimerSettingsMsg timerMsg ->
            Mob.Clock.Settings.update timerMsg model.timerSettings
                |> Tuple.mapBoth
                    (\it -> { model | timerSettings = it })
                    (Cmd.map TimerSettingsMsg)
                |> (\( m, c ) -> UpdateResult m c [])

        TabsMsg tabsMsg ->
            case tabsMsg of
                Mob.Tabs.Tabs.Clicked tab ->
                    ( { model | tab = tab }, Cmd.none )
                        |> (\( m, c ) -> UpdateResult m c [])

        ShareMsg shareMsg ->
            ( model, Mob.Tabs.Share.update shareMsg |> Cmd.map ShareMsg )
                |> (\( m, c ) -> UpdateResult m c [])

        Batch messages ->
            Lib.BatchMsg.update messages model (\ms md -> update ms md |> (\r -> ( r.model, r.command )))
                |> (\( m, c ) -> UpdateResult m c [])


handleClockResult : Model -> Clock.UpdateResult -> ( Model, List (Cmd Msg) )
handleClockResult model clockResult =
    let
        soundResult =
            Sound.handleClockEvents model.sound clockResult.event

        mobbersResult =
            Mob.Tabs.Mobbers.handleClockEvents model.mobbers clockResult.event
    in
    ( { model
        | mobClock = clockResult.model
        , sound = soundResult.model
        , mobbers = mobbersResult.model
      }
    , [ soundResult.command |> Cmd.map SoundMsg
      , clockResult.command |> Cmd.map MainClockMsg
      , mobbersResult.command |> Cmd.map MobbersSettingsMsg
      ]
    )



-- SUBSCRIPTIONS


subscriptions : Sub Msg
subscriptions =
    Time.every 1000 TimePassed



-- EVENTS SUBSCRIPTIONS


eventsMapping : EventsMapping Msg
eventsMapping =
    EventsMapping.map SoundMsg Sound.eventsMapping



-- VIEW


view : Model -> Url.Url -> Html Msg
view model url =
    div
        [ id "mob", class "container" ]
        [ header []
            [ section []
                [ clockView model
                , Mob.Action.actionView
                    { clock = model.mobClock
                    , sound = model.sound
                    , clockSettings = model.timerSettings
                    , pomodoro = model.pomodoroClock
                    }
                    { clock = MainClockMsg
                    , sound = SoundMsg
                    , pomodoro = PomodoroClockMsg
                    , batch = Batch
                    }
                , h2 [] [ Mob.Tabs.Share.shareButton model.name url |> Html.map ShareMsg ]
                ]
            ]
        , Mob.Tabs.Tabs.navView model.tab |> Html.map TabsMsg
        , case model.tab.type_ of
            Mob.Tabs.Tabs.Timer ->
                Mob.Clock.Settings.view model.timerSettings
                    |> Html.map TimerSettingsMsg

            Mob.Tabs.Tabs.Mobbers ->
                Mob.Tabs.Mobbers.view model.mobbers
                    |> Html.map MobbersSettingsMsg

            Mob.Tabs.Tabs.Sound ->
                Sound.settingsView model.sound
                    |> Html.map SoundMsg

            Mob.Tabs.Tabs.Share ->
                Mob.Tabs.Share.view model.name url
                    |> Html.map ShareMsg
        ]


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
        ((Pomodoro.view pomodoroCircle model.pomodoroClock
            |> List.map (Svg.map PomodoroClockMsg)
         )
            ++ Clock.view mobCircle model.mobClock
        )
