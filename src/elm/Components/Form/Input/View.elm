module Components.Form.Input.View exposing (Props, view)

import Css
import Html.Styled as Html
import Html.Styled.Attributes as Attr
import Html.Styled.Events as Evts
import UI.Color as Color
import UI.Palettes as Palettes
import UI.Size as Size
import UI.Space as Space
import UI.Typography.Typography as Typography


type alias Props msg =
    { id : String
    , label : String
    , value : String
    , onChange : String -> msg
    , required : Bool
    }


view : List (Html.Attribute msg) -> Props msg -> Html.Html msg
view attributes props =
    Html.div attributes
        [ Html.label
            [ Attr.for props.id
            , Attr.css
                [ Css.display Css.none
                ]
            ]
            [ Html.text props.label ]
        , Html.input
            [ Attr.type_ "text"
            , Attr.id props.id
            , Attr.value props.value
            , Attr.placeholder props.label
            , Evts.onInput props.onChange
            , Attr.required props.required
            , Attr.css
                [ Css.border Css.zero
                , Css.borderBottom3 (Css.px 2) Css.solid <| Color.toElmCss <| Palettes.monochrome.on.background
                , Css.borderRadius Css.zero
                , Typography.fontSize Typography.m
                , Css.padding Css.zero
                , Css.paddingBottom (Size.toElmCss <| Space.xs)
                , Css.width <| Css.pct 100
                ]
            ]
            [ Html.text props.value ]
        ]
