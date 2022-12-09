module UI.Button.Doc exposing (..)

import Css
import ElmBook.Actions
import ElmBook.Chapter exposing (chapter, render, withComponent)
import ElmBook.ElmCSS exposing (Chapter)
import Html.Styled.Attributes as Attr
import UI.Button.Component as Button
import UI.Icons.Ion
import UI.Row


buttonsChapter : Chapter x
buttonsChapter =
    chapter "Buttons"
        |> withComponent component
        |> render content


variants =
    [ Button.Primary, Button.Secondary ]


sizes =
    [ Button.S, Button.M, Button.L ]


contents =
    [ \text -> Button.Both { icon = UI.Icons.Ion.paperAirplane, text = text }
    , always <| Button.Icon UI.Icons.Ion.check
    , Button.Text
    ]


component =
    UI.Row.row [ Attr.css [ Css.alignItems Css.flexStart ] ]
        []
        (sizes
            |> List.map
                (\size ->
                    Button.button []
                        { content =
                            Button.Both
                                { icon = UI.Icons.Ion.paperAirplane
                                , text = "Label"
                                }
                        , variant = Button.Primary
                        , size = size
                        , action = Button.OnPress <| Just <| ElmBook.Actions.logAction "Click"
                        }
                )
        )


content : String
content =
    """
<component />
"""
