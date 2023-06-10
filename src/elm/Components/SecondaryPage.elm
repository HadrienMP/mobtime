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
import UI.Icons.Ion
import UI.Palettes as Palettes
import UI.Size as Size
import UI.Space as Space
import UI.Text as Text
import Utils



-- Doc


theChapter : Chapter x
theChapter =
    chapter "Secondary Page"
        |> withComponent
            (view
                { onBack = logAction "Back"
                , title = "My Page"
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
    , subTitle : Maybe String
    , content : Html.Html msg
    }


view : Props msg -> Html.Html msg
view { onBack, title, subTitle, content } =
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
            [ Text.h2
                [ Attr.css
                    [ Css.borderBottom3 (Css.px 6)
                        Css.double
                        (Color.toElmCss Palettes.monochrome.on.background)
                    , Css.paddingBottom <| Size.toElmCss Space.xs
                    , Css.marginBottom <| Size.toElmCss Space.xs
                    ]
                ]
                title
            , case subTitle of
                Just it ->
                    Html.p [ Attr.css [ Css.fontWeight Css.lighter ] ] [ Html.text it ]

                Nothing ->
                    Html.text ""
            ]
        , content
        ]
