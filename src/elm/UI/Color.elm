module UI.Color exposing (RGBA255, fromHex, toCss, toElmCss, white)

import Css
import Hex
import Parser exposing ((|.), (|=))


type alias RGBA255 =
    { red : Int, green : Int, blue : Int, alpha : Float }


rgb : Int -> Int -> Int -> RGBA255
rgb red green blue =
    { red = red, green = green, blue = blue, alpha = 1 }


-- Colors


white : RGBA255
white =
    fromHex "#fff"



-- Interop


toElmCss : RGBA255 -> Css.Color
toElmCss { red, green, blue, alpha } =
    Css.rgba red green blue alpha


toCss : RGBA255 -> String
toCss { red, green, blue, alpha } =
    ([ red, green, blue ] |> List.map String.fromInt)
        ++ [ String.fromFloat alpha ]
        |> String.join ", "
        |> (\values -> "rgba(" ++ values ++ ")")



-- Parsing


fromHex : String -> RGBA255
fromHex =
    Parser.run hexColorParser
        >> Result.withDefault
            { red = 255
            , green = 0
            , blue = 0
            , alpha = 1
            }


hexColorParser : Parser.Parser RGBA255
hexColorParser =
    Parser.succeed rgb
        |. Parser.symbol "#"
        |= hexParser
        |= hexParser
        |= hexParser


hexParser : Parser.Parser Int
hexParser =
    Parser.getChompedString
        (Parser.succeed ()
            |. Parser.chompIf (always True)
            |. Parser.chompIf (always True)
        )
        |> Parser.andThen
            (\s ->
                case Hex.fromString <| String.toLower s of
                    Ok it ->
                        Parser.succeed it

                    Err err ->
                        Parser.problem err
            )
