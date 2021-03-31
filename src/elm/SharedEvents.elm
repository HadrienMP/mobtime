port module SharedEvents exposing (..)

import Json.Decode
import Json.Encode
import Lib.Duration exposing (Duration)
import Mobbers.Mobber as Mobber exposing (Mobber)
import Mobbers.Mobbers as Mobbers exposing (Mobbers)
import Sound.Library
import Time


port sendEvent : Json.Encode.Value -> Cmd msg


type ClockEvent
    = Started { time : Time.Posix, alarm : Sound.Library.Sound, length : Duration }
    | Stopped


type Event
    = Clock ClockEvent
    | AddedMobber Mobber
    | DeletedMobber Mobber
    | RotatedMobbers
    | ShuffledMobbers Mobbers
    | TurnLengthChanged Duration
    | SelectedMusicProfile Sound.Library.Profile



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
            Json.Decode.succeed <| Clock Stopped

        "AddedMobber" ->
            Json.Decode.map AddedMobber (Json.Decode.field "mobber" Mobber.jsonDecoder)

        "DeletedMobber" ->
            Json.Decode.map DeletedMobber (Json.Decode.field "mobber" Mobber.jsonDecoder)

        "ShuffledMobbers" ->
            Json.Decode.map ShuffledMobbers (Json.Decode.field "mobbers" Mobbers.decoder)

        "TurnLengthChanged" ->
            Json.Decode.int
                |> Json.Decode.map Lib.Duration.ofSeconds
                |> Json.Decode.field "seconds"
                |> Json.Decode.map TurnLengthChanged

        "RotatedMobbers" ->
            Json.Decode.succeed RotatedMobbers

        "SelectedMusicProfile" ->
            Json.Decode.string
                |> Json.Decode.map Sound.Library.profileFromString
                |> Json.Decode.field "profile"
                |> Json.Decode.map SelectedMusicProfile

        _ ->
            Json.Decode.fail <| "I don't know this event " ++ eventName


startedDecoder : Json.Decode.Decoder Event
startedDecoder =
    Json.Decode.map3
        (\start alarm length -> Clock <| Started { time = start, alarm = alarm, length = length })
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
            Clock clockEvent ->
                clockEventToJson clockEvent

            AddedMobber mobber ->
                [ ( "name", Json.Encode.string "AddedMobber" )
                , ( "mobber", Mobber.toJson mobber )
                ]

            DeletedMobber mobber ->
                [ ( "name", Json.Encode.string "DeletedMobber" )
                , ( "mobber", Mobber.toJson mobber )
                ]

            ShuffledMobbers mobbers ->
                [ ( "name", Json.Encode.string "ShuffledMobbers" )
                , ( "mobbers", Mobbers.toJson mobbers )
                ]

            RotatedMobbers ->
                [ ( "name", Json.Encode.string "RotatedMobbers" ) ]

            TurnLengthChanged duration ->
                [ ( "name", Json.Encode.string "TurnLengthChanged" )
                , ( "seconds", Json.Encode.int <| Lib.Duration.toSeconds duration )
                ]

            SelectedMusicProfile profile ->
                [ ( "name", Json.Encode.string "SelectedMusicProfile" )
                , ( "profile", Json.Encode.string <| Sound.Library.profileToString profile )
                ]


clockEventToJson : ClockEvent -> List ( String, Json.Encode.Value )
clockEventToJson clockEvent =
    case clockEvent of
        Started started ->
            [ ( "name", Json.Encode.string "Started" )
            , ( "time", Json.Encode.int <| Time.posixToMillis started.time )
            , ( "alarm", Json.Encode.string started.alarm )
            , ( "length", Lib.Duration.toJson started.length )
            ]

        Stopped ->
            [ ( "name", Json.Encode.string "Stopped" ) ]
