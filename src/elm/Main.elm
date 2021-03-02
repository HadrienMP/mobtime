port module Main exposing (..)

import Browser
import Browser.Navigation as Nav
import Events
import Html exposing (..)
import Html.Attributes exposing (class, id)
import Html.Events exposing (onClick)
import Json.Decode
import Json.Encode
import Random
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

type State
    = Off
    | On { start : Time.Posix }


type alias Model =
    { state : State
    , now : Time.Posix
    }


init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init _ _ _ =
    ( { state = Off
      , now = Time.millisToPosix 0
      }
    , Task.perform TimePassed Time.now
    )



-- UPDATE


type Msg
    = LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | SendEvent Events.Event
    | ReceiveEvent (Result Json.Decode.Error Events.Event)
    | TimePassed Time.Posix
    | Start
    | StartWithAlarm Sound.Library.Sound


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LinkClicked _ ->
            ( model, Cmd.none )

        UrlChanged _ ->
            ( model, Cmd.none )

        SendEvent event ->
            ( model
            , sendEvent <| Events.toJson event
            )

        ReceiveEvent result ->
            case result of
                Ok event ->
                    ( { model | state = apply event model.state }
                    , Cmd.none
                    )

                Err _ ->
                    ( model, Cmd.none )

        TimePassed now ->
            ( { model | now = now }
            , Cmd.none
            )

        Start ->
            ( model, Random.generate StartWithAlarm <| Sound.Library.pick Sound.Library.ClassicWeird )

        StartWithAlarm sound ->
            ( model
            , sendEvent <| Events.toJson <| Events.Started { start = model.now, alarm = sound }
            )


apply : Events.Event -> State -> State
apply event state =
    case ( event, state ) of
        ( Events.Started start, Off ) ->
            On { start = start.start }

        ( Events.Stopped, On _ ) ->
            Off

        _ ->
            state



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ Time.every 1000 TimePassed
        , receiveEvent
            (\json ->
                ReceiveEvent <| Events.fromJson json
            )
        ]



-- VIEW


view : Model -> Browser.Document Msg
view model =
    let
        toto =
            blah model.now model.state
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


blah : Time.Posix -> State -> Toto
blah now state =
    case state of
        On on ->
            { icon = "fa-square"
            , message = SendEvent Events.Stopped
            , class = "on"
            , text =
                ( now, on.start )
                    |> Tuple.mapBoth Time.posixToMillis Time.posixToMillis
                    |> (\( a, b ) -> b + (2 * 60 * 1000) - a)
                    |> (\a -> a // 1000)
                    |> (\a -> String.fromInt a ++ " s")
            }

        _ ->
            { icon = "fa-play"
            , message = Start
            , class = "off"
            , text = ""
            }
