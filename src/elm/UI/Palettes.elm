module UI.Palettes exposing (..)

import UI.Color exposing (RGBA255)


type alias Palette =
    { error : RGBA255
    , success : RGBA255
    , warn : RGBA255
    , info : RGBA255
    , background : RGBA255
    , surface : RGBA255
    , surfaceActive : RGBA255
    , on :
        { error : RGBA255
        , success : RGBA255
        , warn : RGBA255
        , info : RGBA255
        , background : RGBA255
        , surface : RGBA255
        , surfaceActive : RGBA255
        }
    }

monochrome : Palette
monochrome =
    { error = UI.Color.fromHex "#eb0000"
    , success = UI.Color.fromHex "#35c135"
    , warn = UI.Color.fromHex "#eb8400"
    , info = UI.Color.fromHex "#00a9eb"
    , background = UI.Color.white
    , surface = UI.Color.fromHex "#666666"
    , surfaceActive = UI.Color.fromHex "#999999"
    , on =
        { error = UI.Color.white
        , success = UI.Color.white
        , warn = UI.Color.white
        , info = UI.Color.white
        , background = UI.Color.black
        , surface = UI.Color.white
        , surfaceActive = UI.Color.white
        }
    }