module Components.Mobbers.View exposing (Props, view)

import Css
import Html.Styled as Html
import Html.Styled.Attributes as Attr
import UI.Color as Color
import UI.Palettes as Palettes
import UI.Space as Space
import UI.Typography.Typography as Typography


type alias Props =
    { people : List String, roles : List String }


view : Props -> Html.Html msg
view props =
    let
        numberOfSpecialRoles =
            List.length props.roles

        specialMobbers =
            List.take numberOfSpecialRoles props.people

        realMobbers =
            props.people
                |> List.drop numberOfSpecialRoles
    in
    Html.div
        []
        [ Html.div
            [ Attr.css
                [ Css.displayFlex
                , Css.justifyContent Css.spaceBetween
                , Typography.fontSize Typography.s
                ]
            ]
            (props.roles
                |> List.map (Html.text >> List.singleton >> Html.span [])
            )
        , Html.div
            [ Attr.css
                [ Css.displayFlex
                , Css.justifyContent Css.spaceBetween
                , Typography.fontSize Typography.l
                , Css.lineHeight <| Css.num 1
                , Css.fontWeight Css.bold
                ]
            ]
            (specialMobbers
                |> List.map (Html.text >> List.singleton >> Html.span [])
            )
        , Html.div
            [ Attr.css
                [ Css.justifyContent Css.spaceBetween
                , Css.displayFlex
                , Css.flexWrap Css.wrap
                , Css.marginTop Space.m
                , Css.paddingTop Space.s
                , Css.borderTop3 (Css.px 1) Css.dashed <| Color.toElmCss Palettes.monochrome.on.background
                ]
            ]
            (realMobbers
                |> List.map (Html.text >> List.singleton >> Html.span [])
            )
        ]
