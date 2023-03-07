module UI.Color exposing (RGBA255, black, fromHex, lighten, toCss, toElmCss, toIonIconRgba, white)

import Color
import Color.Convert
import Color.Manipulate
import Css



-- Init


type alias RGBA255 =
    Color.Color



-- FUnctions


opactity : Float -> RGBA255 -> RGBA255
opactity =
    Color.Manipulate.fadeOut


lighten : Float -> RGBA255 -> RGBA255
lighten =
    Color.Manipulate.lighten



-- Colors


white : RGBA255
white =
    fromHex "#ffffff"


black : RGBA255
black =
    fromHex "#000000"



-- Interop


toElmCss : RGBA255 -> Css.Color
toElmCss =
    Color.toRgba
        >> (\{ red, green, blue, alpha } ->
                Css.rgba
                    (red * 255 |> round)
                    (green * 255 |> round)
                    (blue * 255 |> round)
                    alpha
           )


toCss : RGBA255 -> String
toCss =
    Color.toCssString


toIonIconRgba : RGBA255 -> { red : Float, green : Float, blue : Float, alpha : Float }
toIonIconRgba =
    Color.toRgba



-- Parsing


fromHex : String -> RGBA255
fromHex =
    Color.Convert.hexToColor >> Result.withDefault Color.red
