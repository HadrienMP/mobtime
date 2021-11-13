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


map : (model1 -> model2) -> (msg -> msg2) -> UpdateResult model1 msg -> UpdateResult model2 msg2
map modelF cmdF updateResult =
    { model = modelF updateResult.model
    , command = Cmd.map cmdF updateResult.command
    , toasts = updateResult.toasts
    }
