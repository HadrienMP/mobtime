module Lib.Ratio exposing (..)


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


limitTo2 : Ratio -> Ratio
limitTo2 (Ratio ratio) =
    Ratio <|
        if ratio > 2 then
            ratio - (toFloat <| floor ratio) + 1

        else
            ratio
