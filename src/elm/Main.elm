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
import Lib.ListExtras exposing (rotate, uncons)
import Lib.Ratio
import Mobbers.Model exposing (Mobbers)
import Mobbers.Settings
import Random
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


type alias Model =
    { clock : ClockState
    , mobbers : Mobbers
    , mobbersSettings : Mobbers.Settings.Model
    , alarmPlaying : Bool
    , now : Time.Posix
    }


init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init _ _ _ =
    ( { clock = Off
      , mobbers = []
      , mobbersSettings = Mobbers.Settings.init
      , alarmPlaying = False
      , now = Time.millisToPosix 0
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
                |> Result.map (applyTo model)
                |> Result.withDefault ( model, Cmd.none )

        ReceivedHistory eventsResults ->
            ( evolveMany model eventsResults
            , Cmd.none
            )

        TimePassed now ->
            let
                ( clock, command ) =
                    Clock.Model.timePassed now model.clock
            in
            ( { model
                | alarmPlaying = Clock.Model.clockEnded clock
                , now = now
                , clock = clock
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
            ( { model | alarmPlaying = False }
            , Js.Commands.send Js.Commands.StopAlarm
            )

        AlarmEnded ->
            ( { model | alarmPlaying = False }
            , Cmd.none
            )

        UnknownEvent ->
            ( model, Cmd.none )

        GotMobbersSettingsMsg subMsg ->
            Mobbers.Settings.update subMsg model.mobbers model.mobbersSettings
                |> Tuple.mapBoth
                    (\it -> { model | mobbersSettings = it })
                    (Cmd.map GotMobbersSettingsMsg)


evolveMany : Model -> List (Result Json.Decode.Error SharedEvents.Event) -> Model
evolveMany model events =
    case uncons events of
        ( Nothing, _ ) ->
            model

        ( Just (Err _), tail ) ->
            evolveMany model tail

        ( Just (Ok head), tail ) ->
            evolveMany (applyTo model head |> Tuple.first) tail


applyTo : Model -> SharedEvents.Event -> ( Model, Cmd Msg )
applyTo state event =
    case ( event, state.clock ) of
        ( SharedEvents.Started started, Off ) ->
            ( { state
                | clock =
                    On
                        { end = Time.posixToMillis started.time + (10 * 1000) |> Time.millisToPosix
                        , length = started.length
                        , ended = False
                        }
              }
            , Js.Commands.send <| Js.Commands.SetAlarm started.alarm
            )

        ( SharedEvents.Stopped, On _ ) ->
            ( { state
                | clock = Off
                , mobbers = rotate state.mobbers
              }
            , Cmd.none
            )

        ( SharedEvents.AddedMobber mobber, _ ) ->
            ( { state | mobbers = state.mobbers ++ [ mobber ] }, Cmd.none )

        ( SharedEvents.DeletedMobber mobber, _ ) ->
            ( { state | mobbers = List.filter (\m -> m /= mobber) state.mobbers }, Cmd.none )

        ( SharedEvents.RotatedMobbers, _ ) ->
            ( { state | mobbers = rotate state.mobbers }, Cmd.none )

        ( SharedEvents.ShuffledMobbers mobbers, _ ) ->
            ( { state | mobbers = mobbers ++ List.filter (\el -> not <| List.member el mobbers) state.mobbers }, Cmd.none )

        _ ->
            ( state, Cmd.none )



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
                            ++ Circle.draw mobCircle (clockRatio model)
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
            , Mobbers.Settings.view model.mobbers model.mobbersSettings
                |> Html.map GotMobbersSettingsMsg
            ]
        ]
    }


clockRatio : Model -> Lib.Ratio.Ratio
clockRatio model =
    case model.clock of
        Off ->
            Lib.Ratio.full

        On on ->
            Duration.div (Duration.between model.now on.end) on.length
                |> (-) 1
                |> Lib.Ratio.from


type alias ActionDescription =
    { icon : Svg Msg
    , message : Msg
    , text : String
    , class : String
    }


detectAction : Model -> ActionDescription
detectAction model =
    if model.alarmPlaying then
        { icon = Icons.mute
        , message = StopSound
        , class = ""
        , text = ""
        }

    else
        case model.clock of
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
