port module Main exposing (..)

import Browser
import Browser.Navigation as Nav
import Duration
import Html exposing (..)
import Html.Attributes exposing (class, id, type_, value)
import Html.Events exposing (onClick, onInput, onSubmit)
import Js.Commands
import Js.Events
import Json.Decode
import Json.Encode
import Mobbers exposing (Mobber, Mobbers)
import Random
import SharedEvents
import Sound.Library
import Task
import Time
import Url


port sendEvent : Json.Encode.Value -> Cmd msg


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


type ClockState
    = Off
    | On { end : Time.Posix }


type alias SharedState =
    { clock : ClockState
    , mobbers : Mobbers
    }


type AlarmState
    = AlarmOn
    | AlarmOff


type alias Model =
    { sharedState : SharedState
    , alarmState : AlarmState
    , mobberName : String
    , now : Time.Posix
    }


init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init _ _ _ =
    ( { sharedState =
            { clock = Off
            , mobbers = []
            }
      , alarmState = AlarmOff
      , mobberName = ""
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
    | MobberNameChanged String
    | AddMobber


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

        ReceivedHistory eventsResults ->
            ( { model | sharedState = evolveMany model.sharedState eventsResults }
            , Cmd.none
            )

        TimePassed now ->
            case model.sharedState.clock of
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
                        , Js.Commands.send Js.Commands.SoundAlarm
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
            , Js.Commands.send Js.Commands.StopAlarm
            )

        AlarmEnded ->
            ( { model | alarmState = AlarmOff }
            , Cmd.none
            )

        UnknownEvent ->
            ( model, Cmd.none )

        MobberNameChanged name ->
            ( { model | mobberName = name }
            , Cmd.none
            )

        AddMobber ->
            ( { model | mobberName = "" }
            , Mobbers.create model.mobberName model.sharedState.mobbers
                |> SharedEvents.AddedMobber
                |> SharedEvents.toJson
                |> sendEvent
            )


evolveMany : SharedState -> List (Result Json.Decode.Error SharedEvents.Event) -> SharedState
evolveMany sharedState events =
    case uncons events of
        ( Nothing, _ ) ->
            sharedState

        ( Just (Err _), tail ) ->
            evolveMany sharedState tail

        ( Just (Ok head), tail ) ->
            evolveMany (applyTo sharedState head |> Tuple.first) tail


uncons : List a -> ( Maybe a, List a )
uncons list =
    ( list, list )
        |> Tuple.mapBoth List.head List.tail
        |> Tuple.mapSecond (Maybe.withDefault [])


applyTo : SharedState -> SharedEvents.Event -> ( SharedState, Cmd Msg )
applyTo state event =
    case ( event, state.clock ) of
        ( SharedEvents.Started started, Off ) ->
            ( { state | clock = On { end = Time.posixToMillis started.time + (10 * 1000) |> Time.millisToPosix } }
            , Js.Commands.send <| Js.Commands.SetAlarm started.alarm
            )

        ( SharedEvents.Stopped, On _ ) ->
            ( { state
                | clock = Off
                , mobbers = Mobbers.rotate state.mobbers
              }
            , Cmd.none
            )

        ( SharedEvents.AddedMobber mobber, _ ) ->
            ( { state | mobbers = mobber :: state.mobbers }, Cmd.none )

        ( SharedEvents.DeletedMobber mobber, _ ) ->
            ( { state | mobbers = List.filter (\m -> m /= mobber) state.mobbers }, Cmd.none )

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
        , div
            [ id "mobbers", class "tab" ]
            [ form
                [ onSubmit AddMobber ]
                [ input [ type_ "text", onInput MobberNameChanged, value model.mobberName ] []
                , button [ type_ "submit" ] [ i [ class "fas fa-plus" ] [] ]
                ]
            , ul [] (List.map mobberView model.sharedState.mobbers)
            ]
        ]
    }


mobberView : Mobber -> Html Msg
mobberView mobber =
    li []
        [ span [] [ text mobber.name ]
        , button
            [ onClick <| ShareEvent <| SharedEvents.DeletedMobber mobber ]
            [ i [ class "fas fa-times" ] [] ]
        ]


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
            case model.sharedState.clock of
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
