module Doc exposing (SharedState, main)

import Components.Form.Input.Doc
import Components.Form.Toggle.Doc
import Components.Form.Volume.Doc
import Components.Mobbers.Doc
import Components.NavBar.Doc
import Components.Playlist.Doc
import Components.SecondaryPage.Doc
import Components.Socket.Doc
import Css
import Css.Global
import ElmBook exposing (withChapterGroups, withStatefulOptions, withThemeOptions)
import ElmBook.ElmCSS exposing (..)
import ElmBook.StatefulOptions
import ElmBook.ThemeOptions exposing (globals)
import Pages.Mob.Invite.Doc
import Pages.Mob.Mobbers.Doc
import Pages.Mob.Profile.Doc
import Pages.Mob.Settings.Doc
import UI.Button.Doc
import UI.GlobalStyle
import UI.Icons.Doc
import UI.Button.RoundIcon
import UI.Modal.Doc
import UI.Range.Doc
import UI.Toggle.Doc
import UI.Typography.Doc


type alias SharedState =
    { volume : Components.Form.Volume.Doc.State
    , range : UI.Range.Doc.State
    , input : String
    , mobberPageName : String
    }


initialState : SharedState
initialState =
    { volume = Components.Form.Volume.Doc.initState
    , range = UI.Range.Doc.initState
    , input = Components.Form.Input.Doc.initState
    , mobberPageName = Pages.Mob.Mobbers.Doc.initState
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
                    , Css.Global.selector ".elmsh:is(code)"
                        [ Css.width <| Css.pct 100
                        , Css.overflow Css.hidden
                        ]
                    ]
                ]
            ]
        |> withChapterGroups
            [ ( "UI"
              , [ UI.Range.Doc.theChapter
                , UI.Button.Doc.theChapter
                , UI.Toggle.Doc.theChapter
                , UI.Modal.Doc.theChapter
                , UI.Typography.Doc.doc
                , UI.Button.RoundIcon.doc
                , UI.Icons.Doc.doc
                ]
              )
            , ( "Components"
              , [ Components.Socket.Doc.theChapter
                , Components.NavBar.Doc.theChapter
                , Components.SecondaryPage.Doc.theChapter
                , Components.Mobbers.Doc.doc
                , Components.Playlist.Doc.doc
                ]
              )
            , ( "Form"
              , [ Components.Form.Volume.Doc.doc
                , Components.Form.Toggle.Doc.doc
                , Components.Form.Input.Doc.doc
                ]
              )
            , ( "Pages"
              , [ Pages.Mob.Profile.Doc.profileChapter
                , Pages.Mob.Invite.Doc.theChapter
                , Pages.Mob.Settings.Doc.theChapter
                , Pages.Mob.Mobbers.Doc.doc
                ]
              )
            ]
