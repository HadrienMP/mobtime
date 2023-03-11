module Components.SecondaryPage.View exposing (Props, view)

import Css
import Html.Styled as Html
import Html.Styled.Attributes as Attr
import UI.Button.View
import UI.Color as Color
import UI.Column as Column
import UI.Css
import UI.Icons.Ion
import UI.Palettes as Palettes
import UI.Row as Row
import UI.Size as Size
import UI.Space as Space
import UI.Text as Text


type alias Props msg =
    { onBack : msg
    , title : String
    , content : Html.Html msg
    }


view : Props msg -> Html.Html msg
view { onBack, title, content } =
    Column.column2
        [ Attr.css [ UI.Css.gap Space.m ] ]
        [ UI.Button.View.button [ Attr.css [ Css.maxWidth Css.fitContent ] ]
            { content =
                UI.Button.View.Both
                    { icon = UI.Icons.Ion.back
                    , text = "Back"
                    }
            , variant = UI.Button.View.Primary
            , size = UI.Button.View.S
            , action = UI.Button.View.OnPress <| Just onBack
            }
        , Space.spacer
        , Row.row
            [ Attr.css
                [ Css.alignItems Css.end
                , Css.paddingBottom <| Size.toElmCss Space.xs
                , Css.borderBottom3 (Css.px 6) Css.double <|
                    Color.toElmCss <|
                        Palettes.monochrome.on.background
                ]
            ]
            [ Row.Gap <| Size.rem 1 ]
            [ Text.h2 [ Attr.css [ Css.flexGrow <| Css.int 1 ] ] title
            ]
        , content
        ]
