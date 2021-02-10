port module Timer exposing (..)

import Json.Encode


port soundCommands : Json.Encode.Value -> Cmd msg
