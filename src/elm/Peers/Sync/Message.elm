module Peers.Sync.Message exposing (..)

import Iso8601
import Pages.Mob.Name exposing (MobName)
import Peers.Sync.Core exposing (Context, Recipient(..))
import Uuid exposing (Uuid)


type alias SyncMessage =
    { name : String
    , recipient : Maybe String
    , sender : String
    , time : String
    , syncId : String
    , mob : MobName
    }


fromCore : MobName -> Peers.Sync.Core.Message Uuid -> SyncMessage
fromCore mob coreMsg =
    { name =
        case coreMsg.type_ of
            Peers.Sync.Core.ExchangeTime ->
                "ExchangeTime"

            Peers.Sync.Core.TellMeYourTime ->
                "TellMeYourTime"

            Peers.Sync.Core.MyTimeIs ->
                "MyTimeIs"
    , recipient =
        case coreMsg.recipient of
            All ->
                Nothing

            Peer peerId ->
                Just peerId
    , sender = coreMsg.context.peerId
    , time = Iso8601.fromTime coreMsg.context.time
    , syncId = Uuid.toString coreMsg.context.syncId
    , mob = mob
    }


toCore : SyncMessage -> Result String (Peers.Sync.Core.Message Uuid)
toCore msg =
    Result.map3 (\a b c -> ( a, b, c ))
        (Iso8601.toTime msg.time |> Result.mapError (\_ -> "Could not parse the time " ++ msg.time))
        (Uuid.fromString msg.syncId |> Result.fromMaybe ("Could not parse the syncId " ++ msg.syncId))
        (case msg.name of
            "ExchangeTime" ->
                Ok Peers.Sync.Core.ExchangeTime

            "TellMeYourTime" ->
                Ok Peers.Sync.Core.TellMeYourTime

            "MyTimeIs" ->
                Ok Peers.Sync.Core.MyTimeIs

            _ ->
                Err <| "Unkown message type " ++ msg.name
        )
        |> Result.map
            (\( time, syncId, type_ ) ->
                Peers.Sync.Core.Message
                    (Context msg.sender time syncId)
                    type_
                    (case msg.recipient of
                        Just peer ->
                            Peer peer

                        Nothing ->
                            All
                    )
            )
