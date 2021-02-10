module Ratio exposing (..)

type Ratio = Ratio Float

full : Ratio
full =
    Ratio 0

from : Float -> Ratio
from value = Ratio value

apply : Ratio -> Float -> Float
apply r float =
    case r of
        Ratio rf -> rf * float