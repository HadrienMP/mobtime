module Peers.Sync.Core exposing (..)

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


type alias Model a =
    { context : Context a
    , adjustments : TimeAdjustments
    }


type CommandType
    = ExchangeTime
    | TellMeYourTime
    | MyTimeIs


type Recipient
    = All
    | Peer PeerId


type alias Message a =
    { context : Context a
    , type_ : CommandType
    , recipient : Recipient
    }


type alias Context a =
    { peerId : PeerId, time : Time.Posix, syncId : a }


start : Context a -> ( Model a, Message a )
start context =
    ( { context = context, adjustments = Dict.empty }
    , { context = context, type_ = TellMeYourTime, recipient = All }
    )


handle : Message a -> Time.Posix -> Model a -> ( Model a, Maybe (Message a) )
handle command now model =
    case command.type_ of
        ExchangeTime ->
            let
                adjustment =
                    calculateTimeAdjustment model.context.time command.context.time now
            in
            ( { model | adjustments = Dict.insert command.context.peerId adjustment model.adjustments }
            , Just
                { context = model.context
                , type_ = MyTimeIs
                , recipient = Peer command.context.peerId
                }
            )

        TellMeYourTime ->
            ( { model | adjustments = Dict.insert command.context.peerId (RequestedAt now) model.adjustments }
            , Just
                { context = { peerId = model.context.peerId, time = now, syncId = model.context.syncId }
                , type_ = ExchangeTime
                , recipient = Peer command.context.peerId
                }
            )

        MyTimeIs ->
            let
                adjustments =
                    case Dict.get command.context.peerId model.adjustments of
                        Just (RequestedAt t0) ->
                            calculateTimeAdjustment t0 command.context.time now
                                |> (\t -> Dict.insert command.context.peerId t model.adjustments)

                        _ ->
                            model.adjustments
            in
            ( { model | adjustments = adjustments }, Nothing )


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


adjustTimeFrom : PeerId -> Model a -> Time.Posix -> Time.Posix
adjustTimeFrom peerId model toAdjust =
    Dict.get peerId model.adjustments
        |> Maybe.map (adjust toAdjust)
        |> Maybe.withDefault toAdjust


adjust : Time.Posix -> TimeAdjustment -> Time.Posix
adjust toAdjust timeAdjustment =
    case timeAdjustment of
        RequestedAt _ ->
            toAdjust

        Fixed duration ->
            Duration.addToTime duration toAdjust
