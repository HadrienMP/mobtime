port module Model.Events exposing (ClockEvent(..), Event(..), MobEvent, fromJson, mobEventToJson, receiveHistory, receiveOne, sendEvent)

import Json.Decode as Decode
import Json.Encode as Json
import Lib.Duration exposing (Duration)
import Model.MobName exposing (MobName)
import Model.Mobber as Mobber exposing (Mobber)
import Model.Mobbers as Mobbers exposing (Mobbers)
import Model.Roles
import Sounds
import Time


port receiveOne : (Json.Value -> msg) -> Sub msg


port receiveHistory : (List Json.Value -> msg) -> Sub msg


port sendEvent : Json.Value -> Cmd msg


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
    | Unknown Decode.Value
    | PomodoroStopped
    | PomodoroLengthChanged Duration



-- DECODING


fromJson : Decode.Value -> Event
fromJson value =
    Decode.decodeValue eventDecoder value
        |> Result.withDefault (Unknown value)


eventDecoder : Decode.Decoder Event
eventDecoder =
    Decode.field "name" Decode.string
        |> Decode.andThen eventFromNameDecoder


eventFromNameDecoder : String -> Decode.Decoder Event
eventFromNameDecoder eventName =
    case eventName of
        "Started" ->
            startedDecoder

        "Stopped" ->
            Decode.succeed <| Clock Stopped

        "PomodoroStopped" ->
            Decode.succeed <| PomodoroStopped

        "PomodoroLengthChanged" ->
            Decode.int
                |> Decode.map Lib.Duration.ofSeconds
                |> Decode.field "seconds"
                |> Decode.map PomodoroLengthChanged

        "AddedMobber" ->
            Decode.map AddedMobber (Decode.field "mobber" Mobber.jsonDecoder)

        "DeletedMobber" ->
            Decode.map DeletedMobber (Decode.field "mobber" Mobber.jsonDecoder)

        "ShuffledMobbers" ->
            Decode.map ShuffledMobbers (Decode.field "mobbers" Mobbers.decoder)

        "TurnLengthChanged" ->
            Decode.int
                |> Decode.map Lib.Duration.ofSeconds
                |> Decode.field "seconds"
                |> Decode.map TurnLengthChanged

        "RotatedMobbers" ->
            Decode.succeed RotatedMobbers

        "SelectedMusicProfile" ->
            Decode.string
                |> Decode.map Sounds.fromCode
                |> Decode.field "profile"
                |> Decode.map SelectedMusicProfile

        "ChangedRoles" ->
            Model.Roles.decoder
                |> Decode.field "roles"
                |> Decode.map ChangedRoles

        _ ->
            Decode.fail <| "I don't know this event " ++ eventName


startedDecoder : Decode.Decoder Event
startedDecoder =
    Decode.map3
        (\start alarm length -> Clock <| Started { time = start, alarm = alarm, length = length })
        (Decode.field "time" timeDecoder)
        (Decode.field "alarm" Decode.string)
        (Decode.field "length" Lib.Duration.jsonDecoder)


timeDecoder : Decode.Decoder Time.Posix
timeDecoder =
    Decode.int |> Decode.map Time.millisToPosix



-- ENCODING


mobEventToJson : MobEvent -> Json.Value
mobEventToJson event =
    eventToJson event.content
        |> (::) ( "mob", Model.MobName.encode event.mob )
        |> Json.object


eventToJson : Event -> List ( String, Json.Value )
eventToJson event =
    case event of
        Clock clockEvent ->
            clockEventToJson clockEvent

        ChangedRoles roles ->
            [ ( "name", Json.string "ChangedRoles" )
            , ( "roles", Model.Roles.encode roles )
            ]

        AddedMobber mobber ->
            [ ( "name", Json.string "AddedMobber" )
            , ( "mobber", Mobber.toJson mobber )
            ]

        DeletedMobber mobber ->
            [ ( "name", Json.string "DeletedMobber" )
            , ( "mobber", Mobber.toJson mobber )
            ]

        ShuffledMobbers mobbers ->
            [ ( "name", Json.string "ShuffledMobbers" )
            , ( "mobbers", Mobbers.toJson mobbers )
            ]

        RotatedMobbers ->
            [ ( "name", Json.string "RotatedMobbers" ) ]

        TurnLengthChanged duration ->
            [ ( "name", Json.string "TurnLengthChanged" )
            , ( "seconds", Json.int <| Lib.Duration.toSeconds duration )
            ]

        SelectedMusicProfile profile ->
            [ ( "name", Json.string "SelectedMusicProfile" )
            , ( "profile", Json.string <| Sounds.code profile )
            ]

        Unknown value ->
            [ ( "name", Json.string "Unknown" )
            , ( "event", value )
            ]

        PomodoroStopped ->
            [ ( "name", Json.string "PomodoroStopped" ) ]

        PomodoroLengthChanged duration ->
            [ ( "name", Json.string "PomodoroLengthChanged" )
            , ( "seconds", Json.int <| Lib.Duration.toSeconds duration )
            ]


clockEventToJson : ClockEvent -> List ( String, Json.Value )
clockEventToJson clockEvent =
    case clockEvent of
        Started started ->
            [ ( "name", Json.string "Started" )
            , ( "time", Json.int <| Time.posixToMillis started.time )
            , ( "alarm", Json.string started.alarm )
            , ( "length", Lib.Duration.toJson started.length )
            ]

        Stopped ->
            [ ( "name", Json.string "Stopped" ) ]
