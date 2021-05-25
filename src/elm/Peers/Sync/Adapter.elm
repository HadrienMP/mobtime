port module Peers.Sync.Adapter exposing (..)

import Js.Events exposing (..)
import Js.EventsMapping as EventsMapping exposing (EventsMapping)
import Lib.Toaster
import Lib.UpdateResult as UpdateResult exposing (UpdateResult)
import Pages.Mob.Name exposing (MobName)
import Peers.Sync.Core exposing (Context, Model, PeerId, Recipient(..))
import Peers.Sync.Message as Message exposing (SyncMessage)
import Random
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
    { peerId : Maybe PeerId, syncId : Maybe Uuid, time : Maybe Time.Posix, mob : MobName }


type Model
    = Starting StartingModel
    | Started { model : Peers.Sync.Core.Model Uuid, mob : MobName }


init : MobName -> ( Model, Cmd Msg )
init mob =
    ( Starting { peerId = Nothing, syncId = Nothing, time = Nothing, mob = mob }
    , Cmd.batch
        [ Random.generate SyncIdGenerated Uuid.uuidGenerator
        , Task.perform GotTime Time.now
        ]
    )


update : Msg -> Model -> Time.Posix -> UpdateResult Model Msg
update msg m now =
    case m of
        Starting starting ->
            updateStarting msg starting
                |> finish

        Started {model, mob} ->
            case msg of
                GotPeerMessage result ->
                    case result of
                        Ok syncMessage ->
                            Peers.Sync.Core.handle syncMessage now model
                            |> (\(subM, message) ->
                                { model = Started {model = subM, mob = mob }
                                , command = message |> Maybe.map (Message.fromCore mob >> clockSyncOutMessage) |> Maybe.withDefault Cmd.none
                                , toasts = []
                                }
                            )

                        Err error ->
                            { model = m
                            , command = Cmd.none
                            , toasts = [Lib.Toaster.error <| "Could not parse the clock sync message: " ++ error]
                            }
                _ ->
                    UpdateResult.fromModel m





updateStarting : Msg -> StartingModel -> UpdateResult StartingModel Msg
updateStarting msg starting =
    case msg of
        GotSocketId peerId ->
            { starting | peerId = Just peerId } |> UpdateResult.fromModel

        SyncIdGenerated uuid ->
            { starting | syncId = Just uuid } |> UpdateResult.fromModel

        GotTime now ->
            { starting | time = Just now } |> UpdateResult.fromModel

        GotPeerMessage _ ->
            UpdateResult.fromModel starting


finish : UpdateResult StartingModel Msg -> UpdateResult Model Msg
finish updateResult =
    case ( updateResult.model.peerId, updateResult.model.syncId, updateResult.model.time ) of
        ( Just peerId, Just syncId, Just time ) ->
            let
                ( model, message ) =
                    Peers.Sync.Core.start (Context peerId time syncId)
            in
            { model = Started { model = model, mob = updateResult.model.mob }
            , command = message |> Message.fromCore updateResult.model.mob |> clockSyncOutMessage
            , toasts = []
            }

        _ ->
            updateResult
                |> UpdateResult.map Starting identity


subscriptions : Sub Msg
subscriptions =
    clockSyncInMessage (GotPeerMessage << Message.toCore)


jsEventMapping : EventsMapping Msg
jsEventMapping =
    EventsMapping.create [ Js.Events.EventMessage "GotSocketId" GotSocketId]
