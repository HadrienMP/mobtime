module Effect exposing (..)

import Js.Commands
import Shared


type Effect msg
    = Shared Shared.Msg
    | Js Js.Commands.Command
    | Command (Cmd msg)
    | None


map : (a -> b) -> Effect a -> Effect b
map f effect =
    case effect of
        Command cmd ->
            Cmd.map f cmd |> Command

        Shared shared ->
            Shared shared

        Js js ->
            Js js

        None ->
            None
