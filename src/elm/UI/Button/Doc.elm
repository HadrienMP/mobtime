module UI.Button.Doc exposing (..)

import Css
import ElmBook.Actions
import ElmBook.Chapter exposing (chapter, renderComponentList)
import ElmBook.ElmCSS exposing (Chapter)
import Html.Styled.Attributes as Attr
import UI.Button.Component as Button
import UI.Icons.Ion
import UI.Rem
import UI.Row


buttonsChapter : Chapter x
buttonsChapter =
    let
        props =
            { content =
                \size ->
                    Button.Both
                        { icon = UI.Icons.Ion.paperAirplane
                        , text = sizeToString size
                        }
            , variant = Button.Primary
            }
    in
    chapter "Buttons"
        |> renderComponentList
            [ ( "Primary", component props )
            , ( "Secondary", component { props | variant = Button.Secondary } )
            ]


variants =
    [ Button.Primary, Button.Secondary ]


sizes =
    [ Button.S, Button.M, Button.L ]


sizeToString : Button.Size -> String
sizeToString size =
    case size of
        Button.S ->
            "Size S"

        Button.M ->
            "Size M"

        Button.L ->
            "Size L"


contents =
    [ \text -> Button.Both { icon = UI.Icons.Ion.paperAirplane, text = text }
    , always <| Button.Icon UI.Icons.Ion.check
    , Button.Text
    ]


component props =
    UI.Row.row [ Attr.css [ Css.alignItems Css.flexStart ] ]
        [ UI.Row.Gap <| UI.Rem.Rem 0.6 ]
        (sizes
            |> List.map
                (\size ->
                    Button.button []
                        { content = props.content size
                        , variant = props.variant
                        , size = size
                        , action = Button.OnPress <| Just <| ElmBook.Actions.logAction "Click"
                        }
                )
        )
