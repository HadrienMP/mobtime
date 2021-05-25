module Lib.UpdateResult exposing (..)

import Lib.Toaster exposing (Toasts)


type alias UpdateResult model msg =
    { model : model
    , command : Cmd msg
    , toasts : Toasts
    }


fromModel : model -> UpdateResult model msg
fromModel model =
    { model = model
    , command = Cmd.none
    , toasts = []
    }


map : (model1 -> model2) -> (Cmd cmd1 -> Cmd cmd2) -> UpdateResult model1 cmd1 -> UpdateResult model2 cmd2
map modelF cmdF updateResult =
    { model = modelF updateResult.model
    , command = cmdF updateResult.command
    , toasts = updateResult.toasts
    }
