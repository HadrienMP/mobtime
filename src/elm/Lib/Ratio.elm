module Lib.Ratio exposing (Ratio(..), apply, from, full, limit)


type Ratio
    = Ratio Float


full : Ratio
full =
    Ratio 0


limit : { min : Float, max : Float } -> Ratio -> Ratio
limit { min, max } (Ratio a) =
    a |> Basics.min max |> Basics.max min |> Ratio


from : Float -> Ratio
from value =
    Ratio value


apply : Ratio -> Float -> Float
apply (Ratio r) float =
    r * float
