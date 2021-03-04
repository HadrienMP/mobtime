module SharedEvents exposing (..)

import Json.Decode
import Json.Encode
import Sound.Library
import Time


type Event
    = Started { time : Time.Posix, alarm : Sound.Library.Sound }
    | Stopped



-- DECODING


fromJson : Json.Decode.Value -> Result Json.Decode.Error Event
fromJson value =
    Json.Decode.decodeValue eventDecoder value


eventDecoder : Json.Decode.Decoder Event
eventDecoder =
    Json.Decode.field "name" Json.Decode.string
        |> Json.Decode.andThen decoderFromName


decoderFromName : String -> Json.Decode.Decoder Event
decoderFromName eventName =
    case eventName of
        "Started" ->
            startedDecoder

        "Stopped" ->
            Json.Decode.succeed Stopped

        _ ->
            Json.Decode.fail <| "I don't know this event " ++ eventName


startedDecoder : Json.Decode.Decoder Event
startedDecoder =
    Json.Decode.map2
        (\start alarm -> Started { time = start, alarm = alarm })
        (Json.Decode.field "time" timeDecoder)
        (Json.Decode.field "alarm" Json.Decode.string)


timeDecoder : Json.Decode.Decoder Time.Posix
timeDecoder =
    Json.Decode.int |> Json.Decode.map Time.millisToPosix



-- ENCODING


toJson : Event -> Json.Encode.Value
toJson event =
    Json.Encode.object <|
        case event of
            Started started ->
                [ ( "name", Json.Encode.string "Started" )
                , ( "time", Json.Encode.int <| Time.posixToMillis started.time )
                , ( "alarm", Json.Encode.string started.alarm )
                ]

            Stopped ->
                [ ( "name", Json.Encode.string "Stopped" ) ]
