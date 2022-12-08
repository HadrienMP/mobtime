port module Peers.Sync.Adapter exposing (..)

import Effect exposing (Effect)
import Js.Commands
import Js.Events
import Js.EventsMapping as EventsMapping exposing (EventsMapping)
import Lib.Toaster
import Model.MobName exposing (MobName)
import Peers.Sync.Core exposing (Context, Model, PeerId)
import Peers.Sync.Message as Message exposing (SyncMessage)
import Random
import Shared
import Task
import Time
import Uuid exposing (Uuid)


port clockSyncOutMessage : SyncMessage -> Cmd msg


port clockSyncInMessage : (SyncMessage -> msg) -> Sub msg


type Msg
    = GotSocketId PeerId
    | SyncIdGenerated Uuid
    | GotTime Time.Posix
    | GotPeerMessage (Result String (Peers.Sync.Core.Message Uuid))


type alias StartingModel =
    { peerId : Maybe PeerId
    , syncId : Maybe Uuid
    , time : Maybe Time.Posix
    , mob : MobName
    }


type Model
    = Starting StartingModel
    | Started
        { model : Peers.Sync.Core.Model Uuid
        , mob : MobName
        }


init : MobName -> ( Model, Cmd Msg )
init mob =
    ( Starting { peerId = Nothing, syncId = Nothing, time = Nothing, mob = mob }
    , Cmd.batch
        [ Random.generate SyncIdGenerated Uuid.uuidGenerator
        , Js.Commands.send Js.Commands.GetSocketId
        , Task.perform GotTime Time.now
        ]
    )


update : Msg -> Model -> Time.Posix -> ( Model, Effect Shared.Msg Msg )
update msg m now =
    case m of
        Starting starting ->
            updateStarting msg starting
                |> finish

        Started { model, mob } ->
            case msg of
                GotPeerMessage result ->
                    case result of
                        Ok syncMessage ->
                            Peers.Sync.Core.handle syncMessage now model
                                |> (\( subM, message ) ->
                                        ( Started { model = subM, mob = mob }
                                        , message
                                            |> Maybe.map
                                                (Message.fromCore mob
                                                    >> clockSyncOutMessage
                                                    >> Effect.fromCmd
                                                )
                                            |> Maybe.withDefault Effect.none
                                        )
                                   )

                        Err error ->
                            ( m
                            , Effect.fromShared <|
                                Shared.Toast <|
                                    Lib.Toaster.Add <|
                                        Lib.Toaster.error <|
                                            "Could not parse the clock sync message: "
                                                ++ error
                            )

                _ ->
                    ( m, Effect.none )


adjust : Time.Posix -> PeerId -> Model -> Time.Posix
adjust time peer m =
    case m of
        Starting _ ->
            time

        Started { model } ->
            Peers.Sync.Core.adjustTimeFrom peer model time


updateStarting : Msg -> StartingModel -> ( StartingModel, Effect Shared.Msg Msg )
updateStarting msg starting =
    case msg of
        GotSocketId peerId ->
            ( { starting | peerId = Just peerId }, Effect.none )

        SyncIdGenerated uuid ->
            ( { starting | syncId = Just uuid }, Effect.none )

        GotTime now ->
            ( { starting | time = Just now }, Effect.none )

        GotPeerMessage _ ->
            ( starting, Effect.none )


finish : ( StartingModel, Effect Shared.Msg Msg ) -> ( Model, Effect Shared.Msg Msg )
finish ( model, effect ) =
    case ( model.peerId, model.syncId, model.time ) of
        ( Just peerId, Just syncId, Just time ) ->
            let
                ( updated, message ) =
                    Peers.Sync.Core.start (Context peerId time syncId)
            in
            ( Started { model = updated, mob = model.mob }
            , message |> Message.fromCore model.mob |> clockSyncOutMessage |> Effect.fromCmd
            )

        _ ->
            ( Starting model, effect )


subscriptions : Sub Msg
subscriptions =
    clockSyncInMessage (GotPeerMessage << Message.toCore)


jsEventMapping : EventsMapping Msg
jsEventMapping =
    EventsMapping.create [ Js.Events.EventMessage "GotSocketId" GotSocketId ]
