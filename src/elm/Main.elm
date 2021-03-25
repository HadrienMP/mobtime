port module Main exposing (..)

import Browser
import Browser.Navigation as Nav
import Circle
import Clock.Model exposing (ClockState(..))
import Html exposing (..)
import Html.Attributes exposing (class, id)
import Html.Events exposing (onClick)
import Js.Commands
import Js.Events
import Json.Decode
import Json.Encode
import Lib.Duration as Duration exposing (Duration)
import Lib.Icons as Icons
import Lib.Ratio
import Lib.Toaster exposing (Toasts)
import Mobbers.Settings
import Random
import Shared
import SharedEvents
import Sound.Library
import Svg exposing (Svg, svg)
import Svg.Attributes as Svg
import Task
import Time
import Url


port receiveEvent : (Json.Encode.Value -> msg) -> Sub msg


port receiveHistory : (List Json.Encode.Value -> msg) -> Sub msg



-- MAIN


main : Program () Model Msg
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


type alias Model =
    { shared : Shared.State
    , mobbersSettings : Mobbers.Settings.Model
    , alarm : AlarmState
    , now : Time.Posix
    , toasts : Toasts
    }


init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init _ _ _ =
    ( { shared = Shared.init
      , mobbersSettings = Mobbers.Settings.init
      , alarm = Standby
      , now = Time.millisToPosix 0
      , toasts = []
      }
    , Task.perform TimePassed Time.now
    )



-- UPDATE


type Msg
    = LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | ShareEvent SharedEvents.Event
    | ReceivedEvent (Result Json.Decode.Error SharedEvents.Event)
    | ReceivedHistory (List (Result Json.Decode.Error SharedEvents.Event))
    | TimePassed Time.Posix
    | Start
    | StartWithAlarm Sound.Library.Sound
    | StopSound
    | AlarmEnded
    | UnknownEvent
    | GotMobbersSettingsMsg Mobbers.Settings.Msg
    | GotToastMsg Lib.Toaster.Msg


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

        ReceivedEvent eventResult ->
            eventResult
                |> Result.map (Shared.applyTo model.shared)
                |> Result.withDefault ( Shared.init, Cmd.none )
                |> Tuple.mapFirst (\shared -> { model | shared = shared })

        ReceivedHistory eventsResults ->
            ( { model | shared = Shared.evolveMany model.shared eventsResults }
            , Cmd.none
            )

        TimePassed now ->
            let
                ( shared, command ) =
                    Shared.timePassed now model.shared
            in
            ( { model
                | alarm =
                    if Clock.Model.clockEnded shared.clock then
                        case model.alarm of
                            Standby ->
                                Playing

                            _ ->
                                model.alarm

                    else
                        case model.alarm of
                            Stopped ->
                                Standby

                            _ ->
                                model.alarm
                , now = now
                , shared = shared
              }
            , command
            )

        Start ->
            ( model, Random.generate StartWithAlarm <| Sound.Library.pick Sound.Library.ClassicWeird )

        StartWithAlarm sound ->
            ( model
            , SharedEvents.sendEvent <|
                SharedEvents.toJson <|
                    SharedEvents.Started { time = model.now, alarm = sound, length = Duration.ofSeconds 10 }
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



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ Time.every 500 TimePassed
        , receiveEvent <| SharedEvents.fromJson >> ReceivedEvent
        , receiveHistory <| List.map SharedEvents.fromJson >> ReceivedHistory
        , Js.Events.events toMsg
        ]


toMsg : Js.Events.Event -> Msg
toMsg event =
    case event.name of
        "AlarmEnded" ->
            AlarmEnded

        _ ->
            UnknownEvent



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
    { title = "Mob Time"
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
                            ++ Circle.draw mobCircle (Clock.Model.clockRatio model.now model.shared.clock)
                    , button
                        [ id "action"
                        , class action.class
                        , onClick action.message
                        ]
                        [ action.icon
                        , span [ id "time-left" ] [ text action.text ]
                        ]
                    ]
                ]
            , nav []
                [ button [] [ Icons.home ]
                , button [] [ Icons.clock ]
                , button [] [ Icons.people ]
                , button [] [ Icons.sound ]
                , button [] [ Icons.share ]
                ]
            , Mobbers.Settings.view model.shared.mobbers model.mobbersSettings
                |> Html.map GotMobbersSettingsMsg
            , Lib.Toaster.view model.toasts |> Html.map GotToastMsg
            ]
        ]
    }


type alias ActionDescription =
    { icon : Svg Msg
    , message : Msg
    , text : String
    , class : String
    }


detectAction : Model -> ActionDescription
detectAction model =
    case model.alarm of
        Playing ->
            { icon = Icons.mute
            , message = StopSound
            , class = ""
            , text = ""
            }

        _ ->
            case model.shared.clock of
                Off ->
                    { icon = Icons.play
                    , message = Start
                    , class = ""
                    , text = ""
                    }

                On on ->
                    { icon = Icons.stop
                    , message = ShareEvent SharedEvents.Stopped
                    , class = "on"
                    , text =
                        Duration.between model.now on.end
                            |> Duration.toSeconds
                            |> (\a -> String.fromInt a ++ " s")
                    }
