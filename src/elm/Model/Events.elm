port module Model.Events exposing (..)

import Json.Decode
import Json.Encode
import Lib.Duration exposing (Duration)
import Model.MobName exposing (MobName)
import Model.Mobber as Mobber exposing (Mobber)
import Model.Mobbers as Mobbers exposing (Mobbers)
import Model.Roles
import Sounds
import Time


port receiveOne : (Json.Encode.Value -> msg) -> Sub msg


port receiveHistory : (List Json.Encode.Value -> msg) -> Sub msg


port sendEvent : Json.Encode.Value -> Cmd msg


type ClockEvent
    = Started { time : Time.Posix, alarm : Sounds.Sound, length : Duration }
    | Stopped


type alias MobEvent =
    { mob : MobName
    , content : Event
    }


type Event
    = Clock ClockEvent
    | ChangedRoles Model.Roles.Roles
    | AddedMobber Mobber
    | DeletedMobber Mobber
    | RotatedMobbers
    | ShuffledMobbers Mobbers
    | TurnLengthChanged Duration
    | SelectedMusicProfile Sounds.Profile
    | Unknown Json.Decode.Value
    | PomodoroStopped
    | PomodoroLengthChanged Duration



-- DECODING


fromJson : Json.Decode.Value -> Event
fromJson value =
    Json.Decode.decodeValue eventDecoder value
        |> Result.withDefault (Unknown value)


eventDecoder : Json.Decode.Decoder Event
eventDecoder =
    Json.Decode.field "name" Json.Decode.string
        |> Json.Decode.andThen eventFromNameDecoder


eventFromNameDecoder : String -> Json.Decode.Decoder Event
eventFromNameDecoder eventName =
    case eventName of
        "Started" ->
            startedDecoder

        "Stopped" ->
            Json.Decode.succeed <| Clock Stopped

        "PomodoroStopped" ->
            Json.Decode.succeed <| PomodoroStopped

        "PomodoroLengthChanged" ->
            Json.Decode.int
                |> Json.Decode.map Lib.Duration.ofSeconds
                |> Json.Decode.field "seconds"
                |> Json.Decode.map PomodoroLengthChanged

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
                |> Json.Decode.map Sounds.fromCode
                |> Json.Decode.field "profile"
                |> Json.Decode.map SelectedMusicProfile

        "ChangedRoles" ->
            Model.Roles.decoder
                |> Json.Decode.field "roles"
                |> Json.Decode.map ChangedRoles

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


mobEventToJson : MobEvent -> Json.Encode.Value
mobEventToJson event =
    eventToJson event.content
        |> (::) ( "mob", Model.MobName.encode event.mob )
        |> Json.Encode.object


eventToJson : Event -> List ( String, Json.Encode.Value )
eventToJson event =
    case event of
        Clock clockEvent ->
            clockEventToJson clockEvent

        ChangedRoles roles ->
            [ ( "name", Json.Encode.string "ChangedRoles" )
            , ( "roles", Model.Roles.encode roles )
            ]

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
            , ( "profile", Json.Encode.string <| Sounds.code profile )
            ]

        Unknown value ->
            [ ( "name", Json.Encode.string "Unknown" )
            , ( "event", value )
            ]

        PomodoroStopped ->
            [ ( "name", Json.Encode.string "PomodoroStopped" ) ]

        PomodoroLengthChanged duration ->
            [ ( "name", Json.Encode.string "PomodoroLengthChanged" )
            , ( "seconds", Json.Encode.int <| Lib.Duration.toSeconds duration )
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
