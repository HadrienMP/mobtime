module Pages.Mob.Main exposing (..)

import Browser
import Browser.Events exposing (onKeyUp)
import Html exposing (..)
import Html.Attributes exposing (class, classList, id)
import Html.Events exposing (onClick)
import Js.Commands
import Js.Events
import Js.EventsMapping as EventsMapping exposing (EventsMapping)
import Json.Decode
import Lib.Circle
import Lib.Duration as Duration exposing (Duration)
import Lib.Icons.Ion
import Lib.Ratio
import Lib.Toaster exposing (Toasts)
import Lib.UpdateResult exposing (UpdateResult)
import Pages.Mob.Clocks.Clock exposing (ClockState(..))
import Pages.Mob.Clocks.Settings
import Pages.Mob.Mobbers.Settings
import Pages.Mob.Name exposing (MobName)
import Pages.Mob.Sound.Library
import Pages.Mob.Sound.Settings
import Pages.Mob.Tabs.Home
import Pages.Mob.Tabs.Share
import Peers.Events
import Peers.State
import Random
import Svg exposing (Svg, svg)
import Svg.Attributes as Svg
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
    , alarm : AlarmState
    , now : Time.Posix
    , tab : Tab
    , dev : Bool
    }


init : MobName -> UserPreferences.Model -> ( Model, Cmd Msg )
init name preferences =
    ( { name = name
      , shared = Peers.State.init
      , mobbersSettings = Pages.Mob.Mobbers.Settings.init
      , clockSettings = Pages.Mob.Clocks.Settings.init
      , soundSettings = Pages.Mob.Sound.Settings.init preferences.volume
      , alarm = Standby
      , now = Time.millisToPosix 0
      , tab = Main
      , dev = False
      }
    , Js.Commands.send <| Js.Commands.Join name
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
    | UnknownEvent
    | GotMainTabMsg Pages.Mob.Tabs.Home.Msg
    | GotClockSettingsMsg Pages.Mob.Clocks.Settings.Msg
    | GotShareTabMsg Pages.Mob.Tabs.Share.Msg
    | GotMobbersSettingsMsg Pages.Mob.Mobbers.Settings.Msg
    | GotSoundSettingsMsg Pages.Mob.Sound.Settings.Msg
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
                Pages.Mob.Clocks.Clock.Ended ->
                    Playing

                Pages.Mob.Clocks.Clock.Continued ->
                    model.alarm
        , now = now
        , shared = timePassedResult.updated
      }
    , case timePassedResult.turnEvent of
        Pages.Mob.Clocks.Clock.Ended ->
            Js.Commands.send Js.Commands.SoundAlarm

        Pages.Mob.Clocks.Clock.Continued ->
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
                    Peers.State.evolve model.shared event
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
            { model = { model | shared = Peers.State.evolveMany model.shared eventsResults }
            , command = Cmd.none
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

        UnknownEvent ->
            { model = model
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
    [ Js.Events.EventMessage "AlarmEnded" (\_ -> AlarmEnded) ]
        |> EventsMapping.create



-- VIEW


view : Model -> Url.Url -> Browser.Document Msg
view model url =
    let
        action =
            detectAction model

        totalWidth =
            220

        outerRadiant =
            104

        pomodoroCircle =
            Lib.Circle.Circle
                outerRadiant
                (Lib.Circle.Coordinates (outerRadiant + 6) (outerRadiant + 6))
                (Lib.Circle.Stroke 10 "#999")

        mobCircle =
            Lib.Circle.inside pomodoroCircle <| Lib.Circle.Stroke 18 "#666"
    in
    { title = timeLeftTitle action ++ "Mob Time"
    , body =
        [ div [ class "container" ]
            [ header []
                [ section []
                    [ svg
                        [ id "circles"
                        , Svg.width <| String.fromInt totalWidth
                        , Svg.height <| String.fromInt totalWidth
                        ]
                      <|
                        Lib.Circle.draw pomodoroCircle Lib.Ratio.full
                            ++ Lib.Circle.draw mobCircle (Pages.Mob.Clocks.Clock.ratio model.now model.shared.clock)
                    , button
                        [ id "action"
                        , class action.class
                        , onClick action.message
                        ]
                        [ action.icon
                        , span [ id "time-left" ] (action.text |> List.map (\a -> span [] [ text a ]))
                        ]
                    ]
                ]
            , nav []
                [ button [ onClick <| SwitchTab Main, classList [ ( "active", model.tab == Main ) ] ] [ Lib.Icons.Ion.home ]
                , button [ onClick <| SwitchTab Clock, classList [ ( "active", model.tab == Clock ) ] ] [ Lib.Icons.Ion.clock ]
                , button [ onClick <| SwitchTab Mobbers, classList [ ( "active", model.tab == Mobbers ) ] ] [ Lib.Icons.Ion.people ]
                , button [ onClick <| SwitchTab Sound, classList [ ( "active", model.tab == Sound ) ] ] [ Lib.Icons.Ion.sound ]
                , button [ onClick <| SwitchTab Share, classList [ ( "active", model.tab == Share ) ] ] [ Lib.Icons.Ion.share ]
                ]
            , case model.tab of
                Main ->
                    Pages.Mob.Tabs.Home.view model.name url model.shared.mobbers
                        |> Html.map GotMainTabMsg

                Clock ->
                    Pages.Mob.Clocks.Settings.view model.shared.turnLength model.clockSettings
                        |> Html.map GotClockSettingsMsg

                Mobbers ->
                    Pages.Mob.Mobbers.Settings.view model.shared.mobbers model.mobbersSettings
                        |> Html.map GotMobbersSettingsMsg

                Sound ->
                    Pages.Mob.Sound.Settings.view model.soundSettings model.name model.shared.soundProfile
                        |> Html.map GotSoundSettingsMsg

                Share ->
                    Pages.Mob.Tabs.Share.view model.name url
                        |> Html.map GotShareTabMsg
            ]
        ]
    }


type alias ActionDescription =
    { icon : Svg Msg
    , message : Msg
    , text : List String
    , class : String
    }


detectAction : Model -> ActionDescription
detectAction model =
    case model.alarm of
        Playing ->
            { icon = Lib.Icons.Ion.mute
            , message = StopSound
            , class = ""
            , text = []
            }

        _ ->
            case model.shared.clock of
                Off ->
                    { icon = Lib.Icons.Ion.play
                    , message = Start
                    , class = ""
                    , text = []
                    }

                On on ->
                    { icon = Lib.Icons.Ion.stop
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


timeLeftTitle : ActionDescription -> String
timeLeftTitle action =
    case action.text of
        [] ->
            ""

        _ ->
            String.join " " action.text ++ " | "
