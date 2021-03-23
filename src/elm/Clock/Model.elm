module Clock.Model exposing (..)

import Lib.Duration exposing (Duration)
import Time


type ClockState
    = Off
    | On { end : Time.Posix, length : Duration, ended : Bool }
