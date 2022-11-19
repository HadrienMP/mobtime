module UI.Palettes exposing (..)

import Color exposing (Color)
import UI.Color


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
    UI.Color.fromHex "#fff"


black : Color
black =
    UI.Color.fromHex "#000"


monochrome : Palette
monochrome =
    { error = UI.Color.fromHex "#eb0000"
    , success = UI.Color.fromHex "#35c135"
    , warn = UI.Color.fromHex "#eb8400"
    , info = UI.Color.fromHex "#00a9eb"
    , background = white
    , surface = UI.Color.fromHex "#666666"
    , surfaceActive = UI.Color.fromHex "#999999"
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