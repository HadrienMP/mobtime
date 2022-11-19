module UI.Palettes exposing (..)

import Color exposing (Color)
import Hex
import Parser exposing ((|.), (|=))


type alias Palette =
    { error : Color
    , success : Color
    , warn : Color
    , info : Color
    , background : Color
    , surface : Color
    , surfaceActive : Color
    , on :
        { error : Color
        , success : Color
        , warn : Color
        , info : Color
        , background : Color
        , surface : Color
        , surfaceActive : Color
        }
    }


white : Color
white =
    hex "#fff"


black : Color
black =
    hex "#000"


monochrome : Palette
monochrome =
    { error = hex "#eb0000"
    , success = hex "#35c135"
    , warn = hex "#eb8400"
    , info = hex "#00a9eb"
    , background = white
    , surface = hex "#666666"
    , surfaceActive = hex "#999999"
    , on =
        { error = white
        , success = white
        , warn = white
        , info = white
        , background = black
        , surface = white
        , surfaceActive = white
        }
    }


hex : String -> Color.Color
hex =
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
