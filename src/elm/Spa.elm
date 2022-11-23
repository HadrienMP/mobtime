module Spa exposing (..)

import Shared


type Msg msg
    = Shared Shared.Msg
    | Regular msg
