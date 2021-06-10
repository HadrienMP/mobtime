port module Peers.Events exposing (..)

import Json.Decode
import Json.Encode
import Lib.Duration exposing (Duration)
import Pages.Mob.Mobbers.Mobber as Mobber exposing (Mobber)
import Pages.Mob.Mobbers.Mobbers as Mobbers exposing (Mobbers)
import Pages.Mob.Sound.Library
import Peers.Sync.Adapter
import Peers.Sync.Core exposing (PeerId)
import Time


port receiveOne : (Json.Encode.Value -> msg) -> Sub msg


port receiveHistory : (List Json.Encode.Value -> msg) -> Sub msg


port sendEvent : Json.Encode.Value -> Cmd msg


type ClockEvent
    = Started { alarm : Pages.Mob.Sound.Library.Sound, length : Duration }
    | Stopped


type alias MobEvent =
    { mob : String
    , time : Time.Posix
    , peer : Maybe PeerId
    , content : Event
    }


type alias InEvent =
    { content : Event
    , peer : Maybe PeerId
    , time : Time.Posix
    }


adjustTime : Peers.Sync.Adapter.Model -> InEvent -> InEvent
adjustTime syncModel inEvent =
    InEvent inEvent.content inEvent.peer <|
        Peers.Sync.Adapter.adjust inEvent.time inEvent.peer syncModel


type Event
    = Clock ClockEvent
    | AddedMobber Mobber
    | DeletedMobber Mobber
    | RotatedMobbers
    | ShuffledMobbers Mobbers
    | TurnLengthChanged Duration
    | SelectedMusicProfile Pages.Mob.Sound.Library.Profile
    | Unknown Json.Decode.Value
    | PomodoroStopped
    | PomodoroLengthChanged Duration



-- DECODING


fromJson : Json.Decode.Value -> InEvent
fromJson value =
    Json.Decode.decodeValue eventDecoder value
        |> Result.withDefault (InEvent (Unknown value) Nothing (Time.millisToPosix 0))


eventDecoder : Json.Decode.Decoder InEvent
eventDecoder =
    Json.Decode.field "name" Json.Decode.string
        |> Json.Decode.andThen eventFromNameDecoder
        |> Json.Decode.andThen decodeInEvent


decodeInEvent : Event -> Json.Decode.Decoder InEvent
decodeInEvent event =
    Json.Decode.map2 (InEvent event)
        (Json.Decode.maybe <| Json.Decode.field "peerId" Json.Decode.string)
        (Json.Decode.field "time" timeDecoder)


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
                |> Json.Decode.map Pages.Mob.Sound.Library.profileFromString
                |> Json.Decode.field "profile"
                |> Json.Decode.map SelectedMusicProfile

        _ ->
            Json.Decode.fail <| "I don't know this event " ++ eventName


startedDecoder : Json.Decode.Decoder Event
startedDecoder =
    Json.Decode.map2
        (\alarm length -> Clock <| Started { alarm = alarm, length = length })
        (Json.Decode.field "alarm" Json.Decode.string)
        (Json.Decode.field "length" Lib.Duration.jsonDecoder)


timeDecoder : Json.Decode.Decoder Time.Posix
timeDecoder =
    Json.Decode.int |> Json.Decode.map Time.millisToPosix



-- ENCODING


mobEventToJson : MobEvent -> Json.Encode.Value
mobEventToJson event =
    eventToJson event.content
        |> (::) ( "mob", Json.Encode.string event.mob )
        |> (::) ( "peerId", event.peer |> Maybe.map Json.Encode.string |> Maybe.withDefault Json.Encode.null )
        |> (::) ( "time", Json.Encode.int <| Time.posixToMillis event.time )
        |> Json.Encode.object


eventToJson : Event -> List ( String, Json.Encode.Value )
eventToJson event =
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
            , ( "profile", Json.Encode.string <| Pages.Mob.Sound.Library.profileToString profile )
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
            , ( "alarm", Json.Encode.string started.alarm )
            , ( "length", Lib.Duration.toJson started.length )
            ]

        Stopped ->
            [ ( "name", Json.Encode.string "Stopped" ) ]
