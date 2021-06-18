module Pages.Mob.Main exposing (..)

import Browser
import Browser.Events exposing (onKeyUp)
import Css exposing (height, px, width)
import Html.Styled as Html exposing (..)
import Html.Styled.Attributes exposing (class, classList, css, id, title)
import Html.Styled.Events exposing (onClick)
import Js.Commands
import Js.Events
import Js.EventsMapping as EventsMapping exposing (EventsMapping)
import Json.Decode
import Lib.Circle
import Lib.Duration as Duration
import Lib.Icons.Ion
import Lib.UpdateResult as UpdateResult exposing (UpdateResult)
import Pages.Mob.Clocks.Clock as Clock exposing (ClockState(..))
import Pages.Mob.Clocks.Settings
import Pages.Mob.Mobbers.Settings
import Pages.Mob.Name exposing (MobName)
import Pages.Mob.Sound.Library
import Pages.Mob.Sound.Settings
import Pages.Mob.Tabs.Home
import Pages.Mob.Tabs.Share
import Peers.Events
import Peers.State
import Peers.Sync.Adapter exposing (Msg(..))
import Random
import Svg.Styled exposing (Svg, svg)
import Svg.Styled.Attributes as Svg
import Time
import Url
import UserPreferences



-- MODEL


type AlarmState
    = Playing
    | Stopped
    | Standby


type Tab
    = Main
    | Mobbers
    | Clock
    | Sound
    | Share


type alias Model =
    { name : MobName
    , shared : Peers.State.State
    , mobbersSettings : Pages.Mob.Mobbers.Settings.Model
    , clockSettings : Pages.Mob.Clocks.Settings.Model
    , soundSettings : Pages.Mob.Sound.Settings.Model
    , clockSync : Peers.Sync.Adapter.Model
    , alarm : AlarmState
    , now : Time.Posix
    , tab : Tab
    , dev : Bool
    }


init : MobName -> UserPreferences.Model -> ( Model, Cmd Msg )
init name preferences =
    let
        ( clockSync, clockSyncCommand ) =
            Peers.Sync.Adapter.init name
    in
    ( { name = name
      , shared = Peers.State.init
      , mobbersSettings = Pages.Mob.Mobbers.Settings.init
      , clockSettings = Pages.Mob.Clocks.Settings.init
      , soundSettings = Pages.Mob.Sound.Settings.init preferences.volume
      , clockSync = clockSync
      , alarm = Standby
      , now = Time.millisToPosix 0
      , tab = Main
      , dev = False
      }
    , Cmd.batch
        [ Js.Commands.send <| Js.Commands.Join name
        , Cmd.map GotClockSyncMsg clockSyncCommand
        ]
    )



-- UPDATE


type Msg
    = ShareEvent Peers.Events.MobEvent
    | ReceivedEvent Peers.Events.Event
    | ReceivedHistory (List Peers.Events.Event)
    | Start
    | StartWithAlarm Pages.Mob.Sound.Library.Sound
    | StopSound
    | AlarmEnded
    | GotMainTabMsg Pages.Mob.Tabs.Home.Msg
    | GotClockSettingsMsg Pages.Mob.Clocks.Settings.Msg
    | GotShareTabMsg Pages.Mob.Tabs.Share.Msg
    | GotMobbersSettingsMsg Pages.Mob.Mobbers.Settings.Msg
    | GotSoundSettingsMsg Pages.Mob.Sound.Settings.Msg
    | GotClockSyncMsg Peers.Sync.Adapter.Msg
    | SwitchTab Tab
    | KeyPressed Keystroke


timePassed : Time.Posix -> Model -> ( Model, Cmd Msg )
timePassed now model =
    let
        timePassedResult =
            Peers.State.timePassed now model.shared
    in
    ( { model
        | alarm =
            case timePassedResult.turnEvent of
                Clock.Ended ->
                    Playing

                Clock.Continued ->
                    model.alarm
        , now = now
        , shared = timePassedResult.updated
      }
    , case timePassedResult.turnEvent of
        Clock.Ended ->
            Js.Commands.send Js.Commands.SoundAlarm

        Clock.Continued ->
            Cmd.none
    )


update : Msg -> Model -> UpdateResult Model Msg
update msg model =
    case msg of
        ShareEvent event ->
            { model = model
            , command = Peers.Events.sendEvent <| Peers.Events.mobEventToJson event
            , toasts = []
            }

        ReceivedEvent event ->
            let
                ( shared, command ) =
                    Peers.State.evolve event model.shared
            in
            { model =
                { model
                    | shared = shared
                    , alarm =
                        -- Handle alarm (command) as separate from the evolve method ?
                        case event of
                            Peers.Events.Clock (Peers.Events.Started _) ->
                                Stopped

                            _ ->
                                model.alarm
                }
            , command = command
            , toasts = []
            }

        ReceivedHistory eventsResults ->
            let
                ( shared, command ) =
                    Peers.State.evolveMany eventsResults model.shared
            in
            { model = { model | shared = shared }
            , command = command
            , toasts = []
            }

        Start ->
            { model = model
            , command = Random.generate StartWithAlarm <| Pages.Mob.Sound.Library.pick model.shared.soundProfile
            , toasts = []
            }

        StartWithAlarm sound ->
            { model = model
            , command =
                Peers.Events.Started
                    { time = model.now
                    , alarm = sound
                    , length =
                        Duration.div model.shared.turnLength <|
                            if model.dev then
                                20

                            else
                                1
                    }
                    |> Peers.Events.Clock
                    |> Peers.Events.MobEvent model.name
                    |> Peers.Events.mobEventToJson
                    |> Peers.Events.sendEvent
            , toasts = []
            }

        StopSound ->
            { model = { model | alarm = Stopped }
            , command = Js.Commands.send Js.Commands.StopAlarm
            , toasts = []
            }

        AlarmEnded ->
            { model = { model | alarm = Stopped }
            , command = Cmd.none
            , toasts = []
            }

        GotMainTabMsg subMsg ->
            { model = model
            , command = Pages.Mob.Tabs.Home.update subMsg |> Cmd.map GotMainTabMsg
            , toasts = []
            }

        GotMobbersSettingsMsg subMsg ->
            let
                mobbersResult =
                    Pages.Mob.Mobbers.Settings.update subMsg model.shared.mobbers model.name model.mobbersSettings
            in
            { model =
                { model
                    | mobbersSettings = mobbersResult.model
                }
            , command = Cmd.map GotMobbersSettingsMsg mobbersResult.command
            , toasts = mobbersResult.toasts
            }

        SwitchTab tab ->
            { model = { model | tab = tab }
            , command = Cmd.none
            , toasts = []
            }

        GotShareTabMsg subMsg ->
            { model = model
            , command = Pages.Mob.Tabs.Share.update subMsg |> Cmd.map GotShareTabMsg
            , toasts = []
            }

        GotClockSettingsMsg subMsg ->
            let
                ( clockSettings, command ) =
                    Pages.Mob.Clocks.Settings.update subMsg model.clockSettings model.name
            in
            { model = { model | clockSettings = clockSettings }
            , command = Cmd.map GotClockSettingsMsg command
            , toasts = []
            }

        GotSoundSettingsMsg subMsg ->
            let
                ( soundSettings, command ) =
                    Pages.Mob.Sound.Settings.update subMsg model.soundSettings
            in
            { model = { model | soundSettings = soundSettings }
            , command = Cmd.map GotSoundSettingsMsg command
            , toasts = []
            }

        KeyPressed stroke ->
            { model =
                { model
                    | dev = xor model.dev <| stroke == Keystroke "D" True True True
                }
            , command = Cmd.none
            , toasts = []
            }

        GotClockSyncMsg sub ->
            Peers.Sync.Adapter.update sub model.clockSync model.now
                |> UpdateResult.map
                    (\m -> { model | clockSync = m })
                    (Cmd.map GotClockSyncMsg)



-- SUBSCRIPTIONS


type alias Keystroke =
    { key : String
    , ctrl : Bool
    , alt : Bool
    , shift : Bool
    }


subscriptions : Sub Msg
subscriptions =
    Sub.batch
        [ Peers.Events.receiveOne <| Peers.Events.fromJson >> ReceivedEvent
        , Peers.Events.receiveHistory <| List.map Peers.Events.fromJson >> ReceivedHistory
        , Sub.map GotClockSyncMsg Peers.Sync.Adapter.subscriptions
        , onKeyUp <|
            Json.Decode.map KeyPressed <|
                Json.Decode.map4 Keystroke
                    (Json.Decode.field "key" Json.Decode.string)
                    (Json.Decode.field "ctrlKey" Json.Decode.bool)
                    (Json.Decode.field "altKey" Json.Decode.bool)
                    (Json.Decode.field "shiftKey" Json.Decode.bool)
        ]


jsEventMapping : EventsMapping Msg
jsEventMapping =
    EventsMapping.batch
        [ EventsMapping.create <|
            [ Js.Events.EventMessage "AlarmEnded" (\_ -> AlarmEnded)
            , Js.Events.EventMessage "SocketConnected" (GotClockSyncMsg << GotSocketId)
            ]
        , EventsMapping.map GotClockSyncMsg Peers.Sync.Adapter.jsEventMapping
        ]



-- VIEW


view : Model -> Url.Url -> Browser.Document Msg
view model url =
    let
        action =
            detectAction model
    in
    { title = timeLeftTitle action ++ "Mob Time"
    , body = body model url action |> List.map toUnstyled
    }


body : Model -> Url.Url -> ActionDescription -> List (Html Msg)
body model url action =
    let
        outerRadiant =
            84

        offset =
            5

        pomodoroStroke =
            8

        mainStroke =
            14

        totalWidth =
            outerRadiant * 2 + (pomodoroStroke + mainStroke) / 2

        pomodoroCircle =
            Lib.Circle.Circle
                outerRadiant
                (Lib.Circle.Coordinates (outerRadiant + offset) (outerRadiant + offset))
                (Lib.Circle.Stroke pomodoroStroke "#999")

        mobCircle =
            Lib.Circle.inside pomodoroCircle <| Lib.Circle.Stroke mainStroke "#666"
    in
    [ div [ class "container" ]
        [ header []
            [ section []
                [ svg
                    [ id "circles"
                    , Svg.width <| String.fromFloat totalWidth
                    , Svg.height <| String.fromFloat totalWidth
                    ]
                    (Lib.Circle.draw pomodoroCircle (Clock.ratio model.now model.shared.pomodoro)
                        ++ Lib.Circle.draw mobCircle (Clock.ratio model.now model.shared.clock)
                    )
                , button
                    [ id "action"
                    , class action.class
                    , onClick action.message
                    , css
                        [ width (px totalWidth)
                        , height (px totalWidth)
                        ]
                    ]
                    [ action.icon
                    , span [ id "time-left" ] (action.text |> List.map (\a -> span [] [ text a ]))
                    ]
                ]
            ]
        , nav []
            [ button
                [ onClick <| SwitchTab Main
                , classList [ ( "active", model.tab == Main ) ]
                , title "Home"
                ]
                [ Lib.Icons.Ion.home |> fromUnstyled ]
            , button
                [ onClick <| SwitchTab Clock
                , classList [ ( "active", model.tab == Clock ) ]
                , title "Clock Settings"
                ]
                [ Lib.Icons.Ion.clock |> fromUnstyled ]
            , button
                [ onClick <| SwitchTab Mobbers
                , classList [ ( "active", model.tab == Mobbers ) ]
                , title "Mobbers"
                ]
                [ Lib.Icons.Ion.people |> fromUnstyled ]
            , button
                [ onClick <| SwitchTab Sound
                , classList [ ( "active", model.tab == Sound ) ]
                , title "Sound Settings"
                ]
                [ Lib.Icons.Ion.sound |> fromUnstyled ]
            , button
                [ onClick <| SwitchTab Share
                , classList [ ( "active", model.tab == Share ) ]
                , title "Share"
                ]
                [ Lib.Icons.Ion.share |> fromUnstyled ]
            ]
        , case model.tab of
            Main ->
                Pages.Mob.Tabs.Home.view model.name url model.shared.mobbers
                    |> Html.fromUnstyled
                    |> Html.map GotMainTabMsg

            Clock ->
                Pages.Mob.Clocks.Settings.view model.clockSettings model.now model.shared
                    |> Html.fromUnstyled
                    |> Html.map GotClockSettingsMsg

            Mobbers ->
                Pages.Mob.Mobbers.Settings.view model.shared.mobbers model.mobbersSettings
                    |> Html.fromUnstyled
                    |> Html.map GotMobbersSettingsMsg

            Sound ->
                Pages.Mob.Sound.Settings.view model.soundSettings model.name model.shared.soundProfile
                    |> Html.fromUnstyled
                    |> Html.map GotSoundSettingsMsg

            Share ->
                Pages.Mob.Tabs.Share.view model.name url
                    |> Html.fromUnstyled
                    |> Html.map GotShareTabMsg
        ]
    ]


type alias ActionDescription =
    { icon : Svg Msg
    , message : Msg
    , text : List String
    , class : String
    }


detectAction : Model -> ActionDescription
detectAction model =
    case ( model.alarm, model.shared.clock, model.shared.pomodoro ) of
        ( Playing, _, _ ) ->
            { icon = Lib.Icons.Ion.mute |> fromUnstyled
            , message = StopSound
            , class = ""
            , text = []
            }

        ( _, On on, _ ) ->
            { icon = Lib.Icons.Ion.stop |> fromUnstyled
            , message =
                Peers.Events.Clock Peers.Events.Stopped
                    |> Peers.Events.MobEvent model.name
                    |> ShareEvent
            , class = "on"
            , text =
                Duration.between model.now on.end
                    |> (if model.clockSettings.displaySeconds then
                            Duration.toLongString

                        else
                            Duration.toShortString
                       )
            }

        ( _, Off, On pomodoro ) ->
            if Duration.secondsBetween model.now pomodoro.end <= 0 then
                { icon = Lib.Icons.Ion.coffee |> fromUnstyled
                , message =
                    Peers.Events.PomodoroStopped
                        |> Peers.Events.MobEvent model.name
                        |> ShareEvent
                , class = ""
                , text = []
                }

            else
                { icon = Lib.Icons.Ion.play |> fromUnstyled
                , message = Start
                , class = ""
                , text = []
                }

        ( _, Off, _ ) ->
            { icon = Lib.Icons.Ion.play |> fromUnstyled
            , message = Start
            , class = ""
            , text = []
            }


timeLeftTitle : ActionDescription -> String
timeLeftTitle action =
    case action.text of
        [] ->
            ""

        _ ->
            String.join " " action.text ++ " | "
