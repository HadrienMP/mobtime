module Doc exposing (..)

import Css
import Css.Global
import ElmBook exposing (withChapterGroups, withStatefulOptions, withThemeOptions)
import ElmBook.ElmCSS exposing (..)
import ElmBook.StatefulOptions
import ElmBook.ThemeOptions exposing (globals)
import Pages.Profile.Doc
import UI.Button.Doc
import UI.GlobalStyle
import UI.Range.Doc
import UI.Toggle.Doc
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
        |> withThemeOptions
            [ globals
                [ UI.GlobalStyle.globalStyle
                , Css.Global.global
                    [ Css.Global.class "elm-book__component-wrapper"
                        [ Css.Global.descendants
                            [ Css.Global.h2
                                [ Css.margin Css.zero
                                ]
                            ]
                        ]
                    ]
                ]
            ]
        |> withChapterGroups
            [ ( "Atomic"
              , [ UI.Range.Doc.theChapter
                , UI.Button.Doc.theChapter
                , UI.Toggle.Doc.theChapter
                ]
              )
            , ( "Compound"
              , [ Volume.Doc.theChapter
                ]
              )
            , ( "Pages", [ Pages.Profile.Doc.profileChapter ] )
            ]
