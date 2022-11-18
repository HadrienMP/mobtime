module UI.Palettes exposing (..)

import Css exposing (Color, hex)


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
