module Doc exposing (..)

import ElmBook exposing (withChapters, withStatefulOptions, withThemeOptions)
import ElmBook.ElmCSS exposing (..)
import ElmBook.StatefulOptions
import ElmBook.ThemeOptions exposing (globals)
import UI.Button.Doc
import UI.GlobalStyle
import UI.Range.Doc
import Volume.Doc


type alias SharedState =
    { volume : Volume.Doc.State
    , range : UI.Range.Doc.State
    }


initialState : SharedState
initialState =
    { volume = Volume.Doc.initState
    , range = UI.Range.Doc.initState
    }


main : Book SharedState
main =
    book "Mob Time"
        |> withStatefulOptions [ ElmBook.StatefulOptions.initialState initialState ]
        |> withThemeOptions [ globals [ UI.GlobalStyle.globalStyle ] ]
        |> withChapters
            [ Volume.Doc.volumeChapter
            , UI.Range.Doc.rangeChapter
            , UI.Button.Doc.buttonsChapter
            ]
