module Components.Mobbers.View exposing (Props, view)

import Css
import Html.Styled as Html
import Html.Styled.Attributes as Attr
import Lib.ListExtras
import Model.Role as Role exposing (Role)
import UI.Button.Link
import UI.Color as Color
import UI.Column as Column
import UI.Css
import UI.Icons.Captain
import UI.Icons.Common exposing (Icon)
import UI.Icons.Keyboard
import UI.Palettes as Palettes
import UI.Row as Row
import UI.Size as Size
import UI.Space as Space
import UI.Typography.Typography as Typography


type alias Props msg =
    { people : List String
    , roles : List Role
    , onShuffle : msg
    , onRotate : msg
    , onAdd : msg
    }


view : Props msg -> Html.Html msg
view props =
    let
        numberOfSpecialRoles =
            List.length props.roles

        specialMobbers : List ( Role, String )
        specialMobbers =
            props.people |> Lib.ListExtras.zip props.roles

        realMobbers =
            props.people |> List.drop numberOfSpecialRoles
    in
    Column.column2
        [ Attr.css [ Css.lineHeight <| Css.num 1.1 ] ]
        -- TODO delete normal row
        [ Row.row2
            [ Attr.css
                [ UI.Css.gap Space.s
                , Css.justifyContent Css.right
                , Css.borderBottom3 (Css.px 1) Css.solid (Color.toElmCss <| Palettes.monochrome.on.background)
                , Css.paddingBottom <| Size.toElmCss Space.xs
                , Css.marginBottom <| Size.toElmCss Space.s
                ]
            ]
            [ UI.Button.Link.view [ Attr.css [ Typography.fontSize Typography.s ] ]
                { text = "Shuffle"
                , onClick = props.onShuffle
                }
            , UI.Button.Link.view [ Attr.css [ Typography.fontSize Typography.s ] ]
                { text = "Rotate"
                , onClick = props.onRotate
                }
            , UI.Button.Link.view [ Attr.css [ Typography.fontSize Typography.s ] ]
                { text = "Add"
                , onClick = props.onAdd
                }
            ]
        , displaySpecials specialMobbers
        , if List.isEmpty props.roles || List.isEmpty realMobbers then
            none

          else
            separator
        , displayRealMobbers realMobbers props
        ]


none : Html.Html msg
none =
    Html.span [ Attr.css [ Css.display Css.none ] ] []


displayRealMobbers : List String -> Props msg -> Html.Html msg
displayRealMobbers realMobbers props =
    case realMobbers of
        nextUp :: mobbers ->
            let
                lastSpecialRole =
                    props.roles |> List.reverse |> List.head
            in
            Row.row2
                [ Attr.css
                    [ Css.justifyContent Css.spaceBetween
                    , Css.alignItems Css.flexEnd
                    , Css.flexWrap Css.wrap
                    , UI.Css.gap Space.s
                    , Css.paddingBottom <| Size.toElmCss Space.s
                    , Css.borderBottom3 (Css.px 1) Css.solid (Color.toElmCss <| Palettes.monochrome.on.background)
                    ]
                ]
                (Column.column2 []
                    [ lastSpecialRole |> Maybe.map (Role.toNextUp >> displayRoleName) |> Maybe.withDefault none
                    , Html.span []
                        [ Html.text nextUp
                        ]
                    ]
                    :: (mobbers |> List.map (Html.text >> List.singleton >> Html.span []))
                )

        _ ->
            Html.span [] []


displaySpecials : List ( Role, String ) -> Html.Html msg
displaySpecials specialMobbers =
    Row.row2
        [ Attr.css
            [ Css.justifyContent Css.spaceBetween
            , Css.flexWrap Css.wrap
            ]
        ]
        (specialMobbers |> List.map displaySpecial)


displayRoleName : Role -> Html.Html msg
displayRoleName lastSpecialRole =
    Html.span [ Attr.css [ Typography.fontSize Typography.s ] ]
        [ Html.text <| Role.print lastSpecialRole
        ]


separator : Html.Html msg
separator =
    Html.hr
        [ Attr.css
            [ Css.border Css.zero
            , Css.borderTop3 (Css.px 1) Css.dashed <| Color.toElmCss <| Palettes.monochrome.on.background
            , Css.width <| Css.pct 100
            ]
        ]
        []


displaySpecial : ( Role, String ) -> Html.Html msg
displaySpecial ( role, person ) =
    Row.row2 [ Attr.css [ Css.alignItems Css.center, UI.Css.gap <| Size.rem 0.7 ] ]
        [ iconForRole role
            |> Maybe.map
                (\icon ->
                    icon
                        { size = Size.rem 3
                        , color = Palettes.monochrome.on.background
                        }
                )
            |> Maybe.withDefault (Html.span [ Attr.css [ Css.display Css.none ] ] [])
        , Column.column2 []
            [ displayRoleName role
            , Html.span
                [ Attr.css
                    [ Typography.fontSize Typography.l
                    , Css.fontWeight Css.bold
                    ]
                ]
                [ Html.text person ]
            ]
        ]


iconForRole : Role -> Maybe (Icon msg)
iconForRole role =
    if role == Role.driver then
        Just UI.Icons.Keyboard.display

    else if role == Role.navigator then
        Just UI.Icons.Captain.display

    else
        Nothing
