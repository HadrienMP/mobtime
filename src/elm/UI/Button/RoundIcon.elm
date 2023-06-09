module UI.Button.RoundIcon exposing (Props, Target(..), doc, view)

import Css
import ElmBook.Chapter exposing (chapter, render, withComponent)
import ElmBook.ElmCSS exposing (Chapter)
import Html.Styled as Html
import Html.Styled.Attributes as Attr
import Html.Styled.Events as Evts
import UI.Color as Color
import UI.Css
import UI.Icons.Common exposing (Icon)
import UI.Icons.Ion
import UI.Palettes as Palettes
import UI.Size as Size



-- Doc


doc : Chapter x
doc =
    chapter "Link"
        |> withComponent
            (view []
                { target = Link "#here"
                , text = "To somewhere"
                , icon = UI.Icons.Ion.code
                , color = Palettes.monochrome.on.background
                }
            )
        |> render """
## Icon Link
<component />

```elm
UI.Button.RoundIcon.view []
    { target = UI.Button.RoundIcon.Link "#here" -- or UI.Button.RoundIcon.Button Clicked
    , text = "To somewhere"
    , icon = UI.Icons.Ion.code
    , color = UI.Palettes.monochrome.on.background
    }
```
"""



-- View


type Target msg
    = Link String
    | Button msg


type alias Props msg =
    { target : Target msg
    , icon : Icon msg
    , text : String
    , color : Color.RGBA255
    }


view : List (Html.Attribute msg) -> Props msg -> Html.Html msg
view attributes props =
    Html.a
        ([ Attr.css
            [ Css.cursor Css.pointer
            , Css.displayFlex
            , Css.flexDirection Css.column
            , Css.alignItems Css.center
            , Css.maxWidth Css.fitContent
            , UI.Css.gap <| Size.rem 0.2
            , Css.textDecoration Css.none
            , Css.hover [ Css.textDecoration Css.underline ]
            ]
         , case props.target of
            Link url ->
                Attr.href url

            Button msg ->
                Evts.onClick msg
         ]
            ++ attributes
        )
        [ Html.div
            [ Attr.css
                [ Css.border3 (Css.px 2) Css.solid (Color.toElmCss Palettes.monochrome.on.background)
                , Css.borderRadius <| Css.pct 50
                , Css.padding <| Css.rem 0.5
                , Css.maxWidth Css.fitContent
                , Css.backgroundColor <| Color.toElmCss <| Palettes.monochrome.background
                , Css.lineHeight <| Css.num 1
                ]
            ]
            [ props.icon
                { size = Size.rem 1.4
                , color = props.color
                }
            ]
        , Html.span
            [ Attr.css
                [ Css.fontSize <| Css.rem 0.9
                , Css.fontWeight Css.lighter
                , Css.color <| Color.toElmCss <| Palettes.monochrome.on.background
                , Css.textDecoration Css.underline
                ]
            ]
            [ Html.text props.text ]
        ]
