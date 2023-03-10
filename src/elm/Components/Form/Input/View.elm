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
    }


view : Props msg -> Html.Html msg
view props =
    Html.div []
        [ Html.label [ Attr.for props.id, Attr.css [ Css.display Css.none ] ] [ Html.text props.label ]
        , Html.input
            [ Attr.type_ "text"
            , Attr.id props.id
            , Attr.value props.value
            , Attr.placeholder props.label
            , Evts.onInput props.onChange
            , Attr.css
                [ Css.border3 (Css.px 1) Css.solid <| Color.toElmCss <| Palettes.monochrome.on.background
                , Typography.fontSize Typography.m
                , Css.padding2
                    (Size.toElmCss <| Space.xs)
                    (Size.toElmCss <| Space.s)
                ]
            ]
            [ Html.text props.value ]
        ]
