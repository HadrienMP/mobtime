module UI.Rem exposing (..)


type Rem
    = Rem Float


open : Rem -> Float
open (Rem raw) =
    raw


divide : Rem -> Float -> Rem
divide rem divider =
    rem
        |> open
        |> (\numerator -> numerator / divider)
        |> Rem


multiply : Float -> Rem -> Rem
multiply multiplier rem =
    rem
        |> open
        |> (\numerator -> numerator * multiplier)
        |> Rem

add : Rem -> Rem -> Rem
add a b =
    open a + open b |> Rem

subtract : Rem -> Rem -> Rem
subtract a b =
    open a - open b |> Rem


toCssString : Rem -> String
toCssString rem =
    (open rem |> String.fromFloat) ++ "rem"

