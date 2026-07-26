port module Model.Events exposing (ClockEvent(..), Event(..), MobEvent, fromJson, mobEventToJson, receiveHistory, receiveOne, sendEvent)

import Json.Decode as Decode
import Json.Encode as Json
import Lib.Duration exposing (Duration)
import Model.MobName exposing (MobName)
import Model.Mobber as Mobber exposing (Mobber, MobberId)
import Model.Mobbers as Mobbers exposing (Mobbers)
import Model.Roles
import Playlist.All as All
import Playlist.Types exposing (PlaylistCode(..), Playlists, Sound)
import Time


port receiveOne : (Json.Value -> msg) -> Sub msg


port receiveHistory : (List Json.Value -> msg) -> Sub msg


port sendEvent : Json.Value -> Cmd msg


type ClockEvent
    = Started { time : Time.Posix, alarm : Sound, length : Duration }
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
    | ChangedMobbersOrder Mobbers
    | TurnLengthChanged Duration
    | SelectedPlaylists Playlists
    | Unknown Decode.Value
    | PomodoroStopped
    | PomodoroLengthChanged Duration
    | ExtremeModeChanged Bool
    | StopAutomatically Bool
    | ToggledMobber MobberId



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

        "ChangedMobbersOrder" ->
            Decode.map ChangedMobbersOrder (Decode.field "mobbers" Mobbers.decoder)

        "TurnLengthChanged" ->
            Decode.int
                |> Decode.map Lib.Duration.ofSeconds
                |> Decode.field "seconds"
                |> Decode.map TurnLengthChanged

        "RotatedMobbers" ->
            Decode.succeed RotatedMobbers

        "SelectedPlaylists" ->
            Decode.map2 (\first rest -> SelectedPlaylists ( first, rest ))
                (Decode.string
                    |> Decode.map (PlaylistCode >> All.fromCode)
                    |> Decode.field "first"
                )
                (Decode.list Decode.string
                    |> Decode.map (List.map (PlaylistCode >> All.fromCode))
                    |> Decode.field "rest"
                )

        "ChangedRoles" ->
            Model.Roles.decoder
                |> Decode.field "roles"
                |> Decode.map ChangedRoles

        "ExtremeModeChanged" ->
            Decode.bool
                |> Decode.field "value"
                |> Decode.map ExtremeModeChanged

        "StopAutomatically" ->
            Decode.bool
                |> Decode.field "value"
                |> Decode.map StopAutomatically

        "ToggledMobber" ->
            Decode.string
                |> Decode.field "id"
                |> Decode.map Mobber.idFromString
                |> Decode.map ToggledMobber

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

        ChangedMobbersOrder mobbers ->
            [ ( "name", Json.string "ChangedMobbersOrder" )
            , ( "mobbers", Mobbers.toJson mobbers )
            ]

        RotatedMobbers ->
            [ ( "name", Json.string "RotatedMobbers" ) ]

        TurnLengthChanged duration ->
            [ ( "name", Json.string "TurnLengthChanged" )
            , ( "seconds", Json.int <| Lib.Duration.toSeconds duration )
            ]

        SelectedPlaylists ( first, rest ) ->
            [ ( "name", Json.string "SelectedPlaylists" )
            , ( "first", Playlist.Types.codeToJson first.code )
            , ( "rest", Json.list (\playlist -> Playlist.Types.codeToJson playlist.code) rest )
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

        ExtremeModeChanged extreme ->
            [ ( "name", Json.string "ExtremeModeChanged" )
            , ( "value", Json.bool extreme )
            ]

        StopAutomatically stopAutomatically ->
            [ ( "name", Json.string "StopAutomatically" )
            , ( "value", Json.bool stopAutomatically )
            ]

        ToggledMobber id ->
            [ ( "name", Json.string "ToggledMobber" )
            , ( "id", Json.string <| Mobber.idAsString id )
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
