port module SharedEvents exposing (..)

import Json.Decode
import Json.Encode
import Lib.Duration exposing (Duration)
import Mobbers.Model as Mobbers exposing (Mobber, Mobbers)
import Sound.Library
import Time


port sendEvent : Json.Encode.Value -> Cmd msg


type Event
    = Started { time : Time.Posix, alarm : Sound.Library.Sound, length : Duration }
    | Stopped
    | AddedMobber Mobber
    | DeletedMobber Mobber
    | RotatedMobbers
    | ShuffledMobbers Mobbers
    | TurnLengthChanged Duration



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

        "AddedMobber" ->
            Json.Decode.map AddedMobber (Json.Decode.field "mobber" Mobbers.jsonDecoder)

        "DeletedMobber" ->
            Json.Decode.map DeletedMobber (Json.Decode.field "mobber" Mobbers.jsonDecoder)

        "ShuffledMobbers" ->
            Json.Decode.map ShuffledMobbers (Json.Decode.field "mobbers" (Json.Decode.list Mobbers.jsonDecoder))

        "TurnLengthChanged" ->
            Json.Decode.map TurnLengthChanged (Json.Decode.field "seconds" (Json.Decode.map (Lib.Duration.ofSeconds) Json.Decode.int))

        "RotatedMobbers" ->
            Json.Decode.succeed RotatedMobbers

        _ ->
            Json.Decode.fail <| "I don't know this event " ++ eventName


startedDecoder : Json.Decode.Decoder Event
startedDecoder =
    Json.Decode.map3
        (\start alarm length -> Started { time = start, alarm = alarm, length = length })
        (Json.Decode.field "time" timeDecoder)
        (Json.Decode.field "alarm" Json.Decode.string)
        (Json.Decode.field "length" Lib.Duration.jsonDecoder)


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
                , ( "length", Lib.Duration.toJson started.length )
                ]

            Stopped ->
                [ ( "name", Json.Encode.string "Stopped" ) ]

            AddedMobber mobber ->
                [ ( "name", Json.Encode.string "AddedMobber" )
                , ( "mobber", Mobbers.toJson mobber )
                ]

            DeletedMobber mobber ->
                [ ( "name", Json.Encode.string "DeletedMobber" )
                , ( "mobber", Mobbers.toJson mobber )
                ]

            ShuffledMobbers mobbers ->
                [ ( "name", Json.Encode.string "ShuffledMobbers" )
                , ( "mobbers", Json.Encode.list Mobbers.toJson mobbers )
                ]

            RotatedMobbers ->
                [ ( "name", Json.Encode.string "RotatedMobbers" ) ]

            TurnLengthChanged duration ->
                [ ( "name", Json.Encode.string "TurnLengthChanged" )
                , ( "seconds", Json.Encode.int <| Lib.Duration.toSeconds duration )
                ]
