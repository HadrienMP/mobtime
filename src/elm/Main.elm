port module Main exposing (..)

import Browser
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (class, id)
import Html.Events exposing (onClick)
import Json.Decode
import Json.Encode
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


type Event
    = StartedAt Time.Posix
    | Stopped


decodeEvent : Json.Decode.Value -> Result Json.Decode.Error Event
decodeEvent value =
    Json.Decode.field "name" Json.Decode.string
        |> Json.Decode.andThen
            (\a ->
                case a of
                    "StartedAt" ->
                        Json.Decode.field "start" Json.Decode.int
                            |> Json.Decode.map
                                (\ms -> StartedAt <| Time.millisToPosix ms)

                    _ ->
                        Json.Decode.fail <| "I don't know this event " ++ a
            )
        |> (\decoder -> Json.Decode.decodeValue decoder value)


encodeEvent : Event -> Json.Encode.Value
encodeEvent event =
    Json.Encode.object <|
        case event of
            StartedAt now ->
                [ ( "name", Json.Encode.string "StartedAt" )
                , ( "start", Json.Encode.int <| Time.posixToMillis now )
                ]

            Stopped ->
                [ ( "name", Json.Encode.string "Stopped" ) ]


type alias Model =
    { history : List Event
    , now : Time.Posix
    }


init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init _ _ _ =
    ( { history = []
      , now = Time.millisToPosix 0
      }
    , Task.perform TimePassed Time.now
    )



-- UPDATE


type Msg
    = LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | SendEvent Event
    | ReceiveEvent (Result Json.Decode.Error Event)
    | TimePassed Time.Posix


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LinkClicked _ ->
            ( model, Cmd.none )

        UrlChanged _ ->
            ( model, Cmd.none )

        SendEvent event ->
            ( model
            , sendEvent <| encodeEvent event
            )

        ReceiveEvent result ->
            case result of
                Ok event ->
                    ( { model | history = event :: model.history }
                    , Cmd.none
                    )
                Err _ ->
                    ( model, Cmd.none )

        TimePassed now ->
            ( { model | now = now }
            , Cmd.none
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ Time.every 1000 TimePassed
        , receiveEvent
            (\json ->
                ReceiveEvent <| decodeEvent json
            )
        ]



-- VIEW


view : Model -> Browser.Document Msg
view model =
    let
        toto =
            blah model.now <| List.head model.history
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


blah : Time.Posix -> Maybe Event -> Toto
blah now maybeEvent =
    case maybeEvent of
        Just (StartedAt start) ->
            { icon = "fa-square"
            , message = SendEvent Stopped
            , class = "on"
            , text =
                ( now, start )
                    |> Tuple.mapBoth Time.posixToMillis Time.posixToMillis
                    |> (\( a, b ) -> b + (2 * 60 * 1000) - a)
                    |> (\a -> a // 1000)
                    |> (\a -> String.fromInt a ++ " s")
            }

        _ ->
            { icon = "fa-play"
            , message = SendEvent <| StartedAt now
            , class = "off"
            , text = ""
            }
