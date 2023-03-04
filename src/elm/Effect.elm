module Effect exposing (Atomic(..), Effect(..), batch, fromCmd, fromShared, js, map, none, share)

import Js.Commands
import Model.Events exposing (MobEvent)


type Effect sharedMsg msg
    = Atomic (Atomic sharedMsg msg)
    | Batch (List (Atomic sharedMsg msg))


type Atomic sharedMsg msg
    = Shared sharedMsg
    | Js Js.Commands.Command
    | Command (Cmd msg)
    | MobEvent MobEvent
    | None


map : (a -> b) -> Effect sharedMsg a -> Effect sharedMsg b
map f effect =
    case effect of
        Atomic atomic ->
            mapAtomic f atomic |> Atomic

        Batch effects ->
            effects |> List.map (mapAtomic f) |> Batch


mapAtomic : (a -> b) -> Atomic sharedMsg a -> Atomic sharedMsg b
mapAtomic f atomic =
    case atomic of
        Command cmd ->
            Cmd.map f cmd |> Command

        Shared shared ->
            Shared shared

        Js command ->
            Js command

        MobEvent it ->
            MobEvent it

        None ->
            None


fromShared : sharedMsg -> Effect sharedMsg msg
fromShared =
    Atomic << Shared


none : Effect sharedMsg msg
none =
    Atomic None


js : Js.Commands.Command -> Effect sharedMsg msg
js =
    Atomic << Js


share : MobEvent -> Effect sharedMsg msg
share =
    Atomic << MobEvent


fromCmd : Cmd msg -> Effect sharedMsg msg
fromCmd =
    Atomic << Command


batch : List (Effect sharedMsg msg) -> Effect sharedMsg msg
batch effects =
    effects
        |> List.map
            (\effect ->
                case effect of
                    Batch other ->
                        other

                    Atomic atomic ->
                        [ atomic ]
            )
        |> List.foldl (++) []
        |> Batch
