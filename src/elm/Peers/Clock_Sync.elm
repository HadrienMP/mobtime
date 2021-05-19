module Peers.Clock_Sync exposing (..)

import Dict exposing (Dict)
import Lib.Duration as Duration exposing (Duration)
import Time


type alias PeerId =
    String


type TimeAdjustment
    = RequestedAt Time.Posix
    | Fixed Duration


type alias TimeAdjustments =
    Dict PeerId TimeAdjustment


type alias SyncingState a =
    { start : Time.Posix, id : a, adjustments : TimeAdjustments }


type State a
    = NotSynced
    | Syncing (SyncingState a)


type CommandType
    = ExchangeTime
    | TellMeYourTime
    | MyTimeIs


type alias Message a =
    { time : Time.Posix
    , syncId : a
    , peer : PeerId
    , type_ : CommandType
    }


type alias Context a =
    { peerId : PeerId, time : Time.Posix, syncId : a }


start : Context a -> ( State a, Message a )
start context =
    ( Syncing { start = context.time, id = context.syncId, adjustments = Dict.empty }
    , { time = context.time, syncId = context.syncId, peer = context.peerId, type_ = TellMeYourTime }
    )


handle : Message a -> Time.Posix -> State a -> ( State a, Maybe (Message a) )
handle command now state =
    ( evolve command now state, Nothing )


evolve : Message a -> Time.Posix -> State a -> State a
evolve command now state =
    case state of
        Syncing syncing ->
            Syncing <| evolveSyncing command now syncing

        _ ->
            state


evolveSyncing : Message a -> Time.Posix -> SyncingState a -> SyncingState a
evolveSyncing command now syncing =
    if command.syncId == syncing.id then
        case command.type_ of
            ExchangeTime ->
                let
                    adjustment =
                        calculateTimeAdjustment syncing.start command.time now
                in
                { syncing | adjustments = Dict.insert command.peer adjustment syncing.adjustments }

            TellMeYourTime ->
                { syncing | adjustments = Dict.insert command.peer (RequestedAt now) syncing.adjustments }

            MyTimeIs ->
                let
                    adjustments =
                        case Dict.get command.peer syncing.adjustments of
                            Just (RequestedAt t0) ->
                                calculateTimeAdjustment t0 command.time now
                                    |> (\t -> Dict.insert command.peer t syncing.adjustments)

                            _ ->
                                syncing.adjustments
                in
                { syncing | adjustments = adjustments }

    else
        syncing


calculateTimeAdjustment : Time.Posix -> Time.Posix -> Time.Posix -> TimeAdjustment
calculateTimeAdjustment t0 t1 t2 =
    let
        roundTripTime =
            Duration.between t0 t2

        singleTripTime =
            Duration.div roundTripTime 2

        expected =
            Duration.addToTime singleTripTime t0
    in
    Fixed <| Duration.between t1 expected


adjustTimeFrom : PeerId -> State a -> Time.Posix -> Time.Posix
adjustTimeFrom peerId state toAdjust =
    case state of
        NotSynced ->
            toAdjust

        Syncing syncing ->
            Dict.get peerId syncing.adjustments
                |> Maybe.map (adjust toAdjust)
                |> Maybe.withDefault toAdjust


adjust : Time.Posix -> TimeAdjustment -> Time.Posix
adjust toAdjust timeAdjustment =
    case timeAdjustment of
        RequestedAt _ ->
            toAdjust

        Fixed duration ->
            Duration.addToTime duration toAdjust
