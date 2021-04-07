module Lib.UpdateResult exposing (..)

import Lib.Toaster exposing (Toasts)


type alias UpdateResult model msg =
    { model : model
    , command : Cmd msg
    , toasts : Toasts
    }
