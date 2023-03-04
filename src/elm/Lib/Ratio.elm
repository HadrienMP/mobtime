module Lib.Ratio exposing (Ratio(..), apply, from, full)


type Ratio
    = Ratio Float


full : Ratio
full =
    Ratio 0


from : Float -> Ratio
from value =
    Ratio value


apply : Ratio -> Float -> Float
apply (Ratio r) float =
    r * float
