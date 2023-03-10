module Components.SecondaryPage.View exposing (Props, view)

import Css
import Html.Styled as Html
import Html.Styled.Attributes as Attr
import Model.MobName exposing (MobName)
import UI.Button.View
import UI.Color as Color
import UI.Column as Column
import UI.Icons.Ion
import UI.Palettes as Palettes
import UI.Row as Row
import UI.Size as Size
import UI.Space as Space
import UI.Text as Text


type alias Props msg =
    { onBack : msg
    , title : String
    , mob : MobName
    , content : Html.Html msg
    }


view : Props msg -> Html.Html msg
view { onBack, title, mob, content } =
    Column.column
        []
        [ Column.Gap <| Size.rem 1 ]
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
                , Css.paddingBottom <| Css.rem 0.8
                , Css.borderBottom3 (Css.rem 0.1) Css.solid <|
                    Color.toElmCss <|
                        Palettes.monochrome.on.background
                ]
            ]
            [ Row.Gap <| Size.rem 1 ]
            [ Text.h2 [ Attr.css [ Css.flexGrow <| Css.int 1 ] ] title
            , Html.div [] [ Html.text "Mob:" ]
            , Html.div [ Attr.css [ Css.fontWeight Css.bold ] ] [ Html.text <| Model.MobName.print mob ]
            ]
        , content
        ]
