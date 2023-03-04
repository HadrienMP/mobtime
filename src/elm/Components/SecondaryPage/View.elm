module Components.SecondaryPage.View exposing (Props, view)

import Css
import Html.Styled as Html
import Html.Styled.Attributes as Attr
import Model.MobName exposing (MobName)
import UI.Button.View
import UI.Color
import UI.Column
import UI.Icons.Ion
import UI.Palettes
import UI.Rem
import UI.Row
import UI.Space
import UI.Text


type alias Props msg =
    { onBack : msg
    , title : String
    , mob : MobName
    , content : Html.Html msg
    }


view : Props msg -> Html.Html msg
view { onBack, title, mob, content } =
    UI.Column.column
        []
        [ UI.Column.Gap <| UI.Rem.Rem 1 ]
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
        , UI.Space.spacer
        , UI.Row.row
            [ Attr.css
                [ Css.alignItems Css.end
                , Css.paddingBottom <| Css.rem 0.8
                , Css.borderBottom3 (Css.rem 0.1) Css.solid <|
                    UI.Color.toElmCss <|
                        UI.Palettes.monochrome.on.background
                ]
            ]
            [ UI.Row.Gap <| UI.Rem.Rem 1 ]
            [ UI.Text.h2 [ Attr.css [ Css.flexGrow <| Css.int 1 ] ] title
            , Html.div [] [ Html.text "Mob" ]
            , Html.div [ Attr.css [ Css.fontWeight Css.bold ] ] [ Html.text <| Model.MobName.print mob ]
            ]
        , content
        ]
