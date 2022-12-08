module Effect exposing (..)

import Js.Commands
import Shared


type Effect msg
    = Atomic (Atomic msg)
    | Batch (List (Atomic msg))


type Atomic msg
    = Shared Shared.Msg
    | Js Js.Commands.Command
    | Command (Cmd msg)
    | None


map : (a -> b) -> Effect a -> Effect b
map f effect =
    case effect of
        Atomic atomic ->
            mapAtomic f atomic |> Atomic

        Batch effects ->
            effects |> List.map (mapAtomic f) |> Batch


mapAtomic : (a -> b) -> Atomic a -> Atomic b
mapAtomic f atomic =
    case atomic of
        Command cmd ->
            Cmd.map f cmd |> Command

        Shared shared ->
            Shared shared

        Js command ->
            Js command

        None ->
            None


fromShared : Shared.Msg -> Effect msg
fromShared =
    Atomic << Shared


none : Effect msg
none =
    Atomic None


js : Js.Commands.Command -> Effect msg
js =
    Atomic << Js


fromCmd : Cmd msg -> Effect msg
fromCmd =
    Atomic << Command


batch : List (Effect msg) -> Effect msg
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
