module UI.Color exposing (..)

import Color exposing (Color)
import Css
import Hex
import Parser exposing ((|.), (|=))



-- Interop


toElmCss : Color -> Css.Color
toElmCss color =
    Color.toRgba color
        |> (\{ red, green, blue, alpha } ->
                Css.rgba
                    (red * 255 |> round)
                    (green * 255 |> round)
                    (blue * 255 |> round)
                    alpha
           )



-- Parsing


fromHex : String -> Color.Color
fromHex =
    Parser.run hexColorParser
        >> Result.withDefault Color.green


hexColorParser : Parser.Parser Color.Color
hexColorParser =
    Parser.succeed Color.rgb255
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
