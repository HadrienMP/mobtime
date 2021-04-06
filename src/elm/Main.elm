port module Main exposing (..)

import Browser
import Browser.Events exposing (onKeyPress, onKeyUp)
import Browser.Navigation as Nav
import Circle
import Clock.Clock exposing (ClockState(..))
import Clock.Settings
import Html exposing (..)
import Html.Attributes exposing (class, classList, id)
import Html.Events exposing (onClick)
import Js.Commands
import Js.Events
import Js.EventsMapping as EventsMapping exposing (EventsMapping)
import Json.Decode
import Json.Encode
import Lib.BatchMsg
import Lib.Duration as Duration exposing (Duration)
import Lib.Icons.Ion
import Lib.Ratio
import Lib.Toaster exposing (Toasts)
import Pages.Mob.Tabs.Home
import Pages.Mob.Tabs.Share
import Mobbers.Settings
import Random
import Shared
import SharedEvents
import Sound.Library
import Sound.Settings
import Svg exposing (Svg, svg)
import Svg.Attributes as Svg
import Task
import Time
import Url
import UserPreferences


port receiveEvent : (Json.Encode.Value -> msg) -> Sub msg


port receiveHistory : (List Json.Encode.Value -> msg) -> Sub msg



-- MAIN


main : Program UserPreferences.Model Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlChange = UrlChanged
        , onUrlRequest = LinkClicked
        }



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
    { key : Nav.Key
    , url : Url.Url
    , shared : Shared.State
    , mobbersSettings : Mobbers.Settings.Model
    , clockSettings : Clock.Settings.Model
    , soundSettings : Sound.Settings.Model
    , alarm : AlarmState
    , now : Time.Posix
    , toasts : Toasts
    , tab : Tab
    , dev : Bool
    }


init : UserPreferences.Model -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init preferences url key =
    ( { key = key
      , url = url
      , shared = Shared.init
      , mobbersSettings = Mobbers.Settings.init
      , clockSettings = Clock.Settings.init
      , soundSettings = Sound.Settings.init preferences.volume
      , alarm = Standby
      , now = Time.millisToPosix 0
      , toasts = []
      , tab = Main
      , dev = False
      }
    , Cmd.batch
        [ Task.perform TimePassed Time.now
        , Js.Commands.send <| Js.Commands.ChangeVolume preferences.volume
        ]
    )



-- UPDATE


type Msg
    = LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | ShareEvent SharedEvents.Event
    | ReceivedEvent SharedEvents.Event
    | ReceivedHistory (List SharedEvents.Event)
    | TimePassed Time.Posix
    | Start
    | StartWithAlarm Sound.Library.Sound
    | StopSound
    | AlarmEnded
    | UnknownEvent
    | GotMainTabMsg Pages.Mob.Tabs.Home.Msg
    | GotClockSettingsMsg Clock.Settings.Msg
    | GotShareTabMsg Pages.Mob.Tabs.Share.Msg
    | GotMobbersSettingsMsg Mobbers.Settings.Msg
    | GotSoundSettingsMsg Sound.Settings.Msg
    | GotToastMsg Lib.Toaster.Msg
    | SwitchTab Tab
    | Batch (List Msg)
    | KeyPressed Keystroke


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LinkClicked _ ->
            ( model, Cmd.none )

        UrlChanged _ ->
            ( model, Cmd.none )

        ShareEvent event ->
            ( model
            , SharedEvents.sendEvent <| SharedEvents.toJson event
            )

        ReceivedEvent event ->
            event
                |> Shared.evolve model.shared
                |> Tuple.mapFirst
                    (\shared ->
                        { model
                            | shared = shared
                            , alarm =
                                -- Handle alarm (command) as separate from the evolve method ?
                                case event of
                                    SharedEvents.Clock (SharedEvents.Started _) ->
                                        Stopped

                                    _ ->
                                        model.alarm
                        }
                    )

        ReceivedHistory eventsResults ->
            ( { model | shared = Shared.evolveMany model.shared eventsResults }
            , Cmd.none
            )

        TimePassed now ->
            let
                timePassedResult =
                    Shared.timePassed now model.shared
            in
            ( { model
                | alarm =
                    case timePassedResult.turnEvent of
                        Clock.Clock.Ended ->
                            Playing

                        Clock.Clock.Continued ->
                            model.alarm
                , now = now
                , shared = timePassedResult.updated
              }
            , case timePassedResult.turnEvent of
                Clock.Clock.Ended ->
                    Js.Commands.send Js.Commands.SoundAlarm

                Clock.Clock.Continued ->
                    Cmd.none
            )

        Start ->
            ( model, Random.generate StartWithAlarm <| Sound.Library.pick model.shared.soundProfile )

        StartWithAlarm sound ->
            ( model
            , SharedEvents.Started
                { time = model.now
                , alarm = sound
                , length =
                    Duration.div model.shared.turnLength <|
                        if model.dev then
                            20

                        else
                            1
                }
                |> SharedEvents.Clock
                |> SharedEvents.toJson
                |> SharedEvents.sendEvent
            )

        StopSound ->
            ( { model | alarm = Stopped }
            , Js.Commands.send Js.Commands.StopAlarm
            )

        AlarmEnded ->
            ( { model | alarm = Stopped }
            , Cmd.none
            )

        UnknownEvent ->
            ( model, Cmd.none )

        GotMainTabMsg subMsg ->
            ( model, Pages.Mob.Tabs.Home.update subMsg |> Cmd.map GotMainTabMsg )

        GotMobbersSettingsMsg subMsg ->
            let
                mobbersResult =
                    Mobbers.Settings.update subMsg model.shared.mobbers model.mobbersSettings

                ( toasts, commands ) =
                    Lib.Toaster.add mobbersResult.toasts model.toasts
            in
            ( { model
                | mobbersSettings = mobbersResult.updated
                , toasts = toasts
              }
            , Cmd.batch <|
                Cmd.map GotMobbersSettingsMsg mobbersResult.command
                    :: List.map (Cmd.map GotToastMsg) commands
            )

        GotToastMsg subMsg ->
            Lib.Toaster.update subMsg model.toasts
                |> Tuple.mapBoth
                    (\toasts -> { model | toasts = toasts })
                    (Cmd.map GotToastMsg)

        SwitchTab tab ->
            ( { model | tab = tab }, Cmd.none )

        Batch messages ->
            Lib.BatchMsg.update messages model update

        GotShareTabMsg subMsg ->
            ( model, Pages.Mob.Tabs.Share.update subMsg |> Cmd.map GotShareTabMsg )

        GotClockSettingsMsg subMsg ->
            Clock.Settings.update subMsg model.clockSettings
                |> Tuple.mapBoth
                    (\a -> { model | clockSettings = a })
                    (Cmd.map GotClockSettingsMsg)

        GotSoundSettingsMsg subMsg ->
            Sound.Settings.update subMsg model.soundSettings
                |> Tuple.mapBoth
                    (\a -> { model | soundSettings = a })
                    (Cmd.map GotSoundSettingsMsg)

        KeyPressed stroke ->
            ( { model
                | dev = xor model.dev <| stroke == Keystroke "D" True True True
              }
            , Cmd.none
            )



-- SUBSCRIPTIONS


type alias Keystroke =
    { key : String
    , ctrl : Bool
    , alt : Bool
    , shift : Bool
    }


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ Time.every 500 TimePassed
        , receiveEvent <| SharedEvents.fromJson >> ReceivedEvent
        , receiveHistory <| List.map SharedEvents.fromJson >> ReceivedHistory
        , Js.Events.events toMsg
        , onKeyUp <|
            Json.Decode.map KeyPressed <|
                Json.Decode.map4 Keystroke
                    (Json.Decode.field "key" Json.Decode.string)
                    (Json.Decode.field "ctrlKey" Json.Decode.bool)
                    (Json.Decode.field "altKey" Json.Decode.bool)
                    (Json.Decode.field "shiftKey" Json.Decode.bool)
        ]


toMsg : Js.Events.Event -> Msg
toMsg event =
    case event.name of
        "AlarmEnded" ->
            AlarmEnded

        _ ->
            Lib.Toaster.eventsMapping
                |> EventsMapping.map GotToastMsg
                |> EventsMapping.dispatch event
                |> Batch



-- VIEW


view : Model -> Browser.Document Msg
view model =
    let
        action =
            detectAction model

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
                        Circle.draw pomodoroCircle Lib.Ratio.full
                            ++ Circle.draw mobCircle (Clock.Clock.ratio model.now model.shared.clock)
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
                    Pages.Mob.Tabs.Home.view "Awesome" model.url model.shared.mobbers
                        |> Html.map GotMainTabMsg

                Clock ->
                    Clock.Settings.view model.shared.turnLength model.clockSettings
                        |> Html.map GotClockSettingsMsg

                Mobbers ->
                    Mobbers.Settings.view model.shared.mobbers model.mobbersSettings
                        |> Html.map GotMobbersSettingsMsg

                Sound ->
                    Sound.Settings.view model.soundSettings model.shared.soundProfile
                        |> Html.map GotSoundSettingsMsg

                Share ->
                    Pages.Mob.Tabs.Share.view "Awesome" model.url
                        |> Html.map GotShareTabMsg
            , Lib.Toaster.view model.toasts |> Html.map GotToastMsg
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
                    , message = ShareEvent <| SharedEvents.Clock SharedEvents.Stopped
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
        [] -> ""
        _ -> String.join " " action.text ++ " | "