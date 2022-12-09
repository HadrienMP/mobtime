module Doc exposing (..)

import ElmBook exposing (withChapters, withStatefulOptions)
import ElmBook.ElmCSS exposing (..)
import ElmBook.StatefulOptions
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
        |> withChapters
            [ Volume.Doc.volumeChapter
            , UI.Range.Doc.rangeChapter
            ]
