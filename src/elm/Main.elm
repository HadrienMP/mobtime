port module Main exposing (..)

import Browser
import Browser.Navigation as Nav
import Duration
import Html exposing (..)
import Html.Attributes exposing (class, id)
import Html.Events exposing (onClick)
import Json.Decode
import Json.Encode
import Out.Commands
import Out.Events
import Random
import SharedEvents
import Sound.Library
import Task
import Time
import Url


port sendEvent : Json.Encode.Value -> Cmd msg


port receiveEvent : (Json.Encode.Value -> msg) -> Sub msg



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


type SharedState
    = Off
    | On { end : Time.Posix }


type AlarmState
    = AlarmOn
    | AlarmOff


type alias Model =
    { sharedState : SharedState
    , alarmState : AlarmState
    , now : Time.Posix
    }


init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init _ _ _ =
    ( { sharedState = Off
      , alarmState = AlarmOff
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
    | TimePassed Time.Posix
    | Start
    | StartWithAlarm Sound.Library.Sound
    | StopSound
    | AlarmEnded
    | UnknownEvent


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LinkClicked _ ->
            ( model, Cmd.none )

        UrlChanged _ ->
            ( model, Cmd.none )

        ShareEvent event ->
            ( model
            , sendEvent <| SharedEvents.toJson event
            )

        ReceivedEvent eventResult ->
            eventResult
                |> Result.map (applyTo model.sharedState)
                |> Result.withDefault ( model.sharedState, Cmd.none )
                |> Tuple.mapFirst (\it -> { model | sharedState = it })

        TimePassed now ->
            case model.sharedState of
                Off ->
                    ( { model | now = now }, Cmd.none )

                On on ->
                    let
                        timeLeft =
                            Duration.between now on.end
                    in
                    if Duration.toSeconds timeLeft == 0 then
                        ( { model
                            | now = now
                            , alarmState = AlarmOn
                          }
                        , Out.Commands.send Out.Commands.SoundAlarm
                        )

                    else
                        ( { model | now = now }, Cmd.none )

        Start ->
            ( model, Random.generate StartWithAlarm <| Sound.Library.pick Sound.Library.ClassicWeird )

        StartWithAlarm sound ->
            ( model
            , sendEvent <| SharedEvents.toJson <| SharedEvents.Started { time = model.now, alarm = sound }
            )

        StopSound ->
            ( { model | alarmState = AlarmOff }
            , Out.Commands.send Out.Commands.StopAlarm
            )

        AlarmEnded ->
            ( { model | alarmState = AlarmOff }
            , Cmd.none
            )

        UnknownEvent ->
            (model, Cmd.none)



applyTo : SharedState -> SharedEvents.Event -> ( SharedState, Cmd Msg )
applyTo state event =
    case ( event, state ) of
        ( SharedEvents.Started started, Off ) ->
            ( On { end = (Time.posixToMillis started.time) + (1 * 60 * 1000 // 3) |> Time.millisToPosix }
            , Out.Commands.send <| Out.Commands.SetAlarm started.alarm
            )

        ( SharedEvents.Stopped, On _ ) ->
            ( Off, Cmd.none )

        _ ->
            ( state, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ Time.every 500 TimePassed
        , receiveEvent <| SharedEvents.fromJson >> ReceivedEvent
        , Out.Events.events toMsg
        ]

toMsg : Out.Events.Event -> Msg
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
        toto =
            blah model
    in
    { title = "Mob Time"
    , body =
        [ header []
            [ section []
                [ button
                    [ id "action"
                    , class toto.class
                    , onClick toto.message
                    ]
                    [ i [ class <| "fas " ++ toto.icon ] []
                    , span [ id "time-left" ] [ text toto.text ]
                    ]
                ]
            ]
        ]
    }


type alias Toto =
    { icon : String
    , message : Msg
    , text : String
    , class : String
    }


blah : Model -> Toto
blah model =
    case model.alarmState of
        AlarmOn ->
            { icon = "fa-volume-mute"
            , message = StopSound
            , class = ""
            , text = ""
            }

        AlarmOff ->
            case model.sharedState of
                On on ->
                    { icon = "fa-square"
                    , message = ShareEvent SharedEvents.Stopped
                    , class = "on"
                    , text =
                        Duration.between model.now on.end
                            |> Duration.toSeconds
                            |> (\a -> String.fromInt a ++ " s")
                    }

                Off ->
                    { icon = "fa-play"
                    , message = Start
                    , class = ""
                    , text = ""
                    }
