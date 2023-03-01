module UI.Modal.Doc exposing (..)

import Css
import ElmBook.Actions
import ElmBook.Chapter exposing (chapter, render, withComponent)
import ElmBook.ElmCSS exposing (Chapter)
import Html.Styled as Html
import Html.Styled.Attributes as Attr
import UI.Color
import UI.Modal.View


theChapter : Chapter x
theChapter =
    chapter "Modal"
        |> withComponent
            (Html.div [ Attr.css [ Css.position Css.relative, Css.height <| Css.vh 50 ] ]
                [ UI.Modal.View.view
                    { onClose = ElmBook.Actions.logAction "Close modal"
                    , content =
                        Html.div
                            [ Attr.css
                                [ Css.height <| Css.pct 100
                                , Css.width <| Css.pct 100
                                , Css.backgroundColor <| UI.Color.toElmCss <| UI.Color.fromHex "#2aaae7"
                                , Css.displayFlex
                                , Css.alignItems Css.center
                                , Css.justifyContent Css.center
                                ]
                            ]
                            [ Html.text "Content" ]
                    }
                ]
            )
        |> render """
```elm
UI.Modal.View.view
  { onClose = Closed
  , content = 
      Html.text "Content"
  }
```
<component />
"""
