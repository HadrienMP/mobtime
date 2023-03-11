module UI.Button.Link exposing (view)

import Css
import Html.Styled as Html
import Html.Styled.Attributes as Attr
import Html.Styled.Events as Evts
import UI.Color as Color
import UI.Palettes as Palettes


view :
    List (Html.Attribute msg)
    -> { text : Html.Html msg, onClick : msg }
    -> Html.Html msg
view attributes props =
    Html.button
        (attributes
            ++ [ Attr.css
                    [ Css.textDecoration Css.underline
                    , Css.backgroundColor Css.transparent
                    , Css.border Css.zero
                    , Css.padding Css.zero
                    , Css.cursor Css.pointer
                    , Css.color <| Color.toElmCss <| Palettes.monochrome.on.background
                    , Css.hover [ Css.backgroundColor Css.transparent ]
                    ]
               , Evts.onClick props.onClick
               ]
        )
        [ props.text ]
