module UI.Palettes exposing (Palette, monochrome)

import UI.Color as Color exposing (RGBA255)


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
    { error = Color.fromHex "#eb0000"
    , success = Color.fromHex "#35c135"
    , warn = Color.fromHex "#eb8400"
    , info = Color.fromHex "#00a9eb"
    , background = Color.white
    , surface = Color.black
    , surfaceActive = Color.fromHex "#999999"
    , on =
        { error = Color.white
        , success = Color.white
        , warn = Color.white
        , info = Color.white
        , background = Color.black
        , surface = Color.white
        , surfaceActive = Color.white
        }
    }
