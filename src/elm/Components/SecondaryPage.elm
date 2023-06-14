module Components.SecondaryPage exposing (Props, theChapter, view)

import Css
import ElmBook.Actions exposing (logAction)
import ElmBook.Chapter exposing (chapter, render, withComponent)
import ElmBook.ElmCSS exposing (Chapter)
import Html.Styled as Html
import Html.Styled.Attributes as Attr
import UI.Button.View
import UI.Color as Color
import UI.Column as Column
import UI.Css
import UI.Icons.Common exposing (Icon)
import UI.Icons.Ion
import UI.Palettes as Palettes
import UI.Size as Size
import UI.Space as Space
import Utils



-- Doc


theChapter : Chapter x
theChapter =
    chapter "Secondary Page"
        |> withComponent
            (view
                { onBack = logAction "Back"
                , title = "My Page"
                , icon = UI.Icons.Ion.bug
                , subTitle = Just "Subtitle"
                , content = Utils.placeholder <| Size.rem 10
                }
            )
        |> render """
<component />
```elm
type Msg
    = Back
    | ...

Components.SecondaryPage.view
    { onBack = logAction "Back"
    , title = "My Page"
    , subTitle = Just "Subtitle"
    , content = Utils.placeholder <| Size.rem 10
    }
```
"""



-- View


type alias Props msg =
    { onBack : msg
    , title : String
    , icon : Icon msg
    , subTitle : Maybe String
    , content : Html.Html msg
    }


view : Props msg -> Html.Html msg
view { onBack, title, icon, subTitle, content } =
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
        , Html.div []
            [ Html.h2
                [ Attr.css
                    [ Css.displayFlex
                    , Css.alignItems Css.center
                    , Css.property "gap" "0.5rem"
                    , Css.borderBottom3 (Css.px 6)
                        Css.double
                        (Color.toElmCss Palettes.monochrome.on.background)
                    , Css.paddingBottom <| Size.toElmCss Space.xs
                    , Css.marginBottom <| Size.toElmCss Space.xs
                    , Css.fontSize <| Css.rem 2
                    , Css.lineHeight <| Css.num 1.1
                    ]
                ]
                [ icon
                    { size = Size.rem 2.2
                    , color = Palettes.monochrome.on.background
                    }
                , Html.text title
                ]
            , case subTitle of
                Just it ->
                    Html.p [ Attr.css [ Css.fontWeight Css.lighter ] ] [ Html.text it ]

                Nothing ->
                    Html.text ""
            ]
        , content
        ]
