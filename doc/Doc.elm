module Doc exposing (..)

import Components.NavBar.Doc
import Components.Share.Doc
import Components.Socket.Doc
import Components.Volume.Doc
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


type alias SharedState =
    { volume : Components.Volume.Doc.State
    , range : UI.Range.Doc.State
    }


initialState : SharedState
initialState =
    { volume = Components.Volume.Doc.initState
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
                            [ Css.Global.h1
                                [ Css.margin Css.zero
                                ]
                            , Css.Global.h2
                                [ Css.margin Css.zero
                                ]
                            ]
                        ]
                    ]
                ]
            ]
        |> withChapterGroups
            [ ( "UI"
              , [ UI.Range.Doc.theChapter
                , UI.Button.Doc.theChapter
                , UI.Toggle.Doc.theChapter
                ]
              )
            , ( "Components"
              , [ Components.Volume.Doc.theChapter
                , Components.Socket.Doc.theChapter
                , Components.Share.Doc.theChapter
                , Components.NavBar.Doc.theChapter
                ]
              )
            , ( "Pages", [ Pages.Profile.Doc.profileChapter ] )
            ]
