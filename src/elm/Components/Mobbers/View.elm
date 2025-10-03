module Components.Mobbers.View exposing (Props, iconForRole, view)

import Css
import Html.Styled as Html
import Html.Styled.Attributes as Attr
import Lib.ListExtras
import Lib.StringExtra
import Model.Mobber
import Model.Role as Role exposing (Role)
import UI.Button.Link
import UI.Color as Color
import UI.Column as Column
import UI.Css
import UI.Icons.Captain
import UI.Icons.Common exposing (Icon)
import UI.Icons.Ion
import UI.Icons.Keyboard
import UI.Palettes as Palettes
import UI.Row as Row
import UI.Size as Size
import UI.Space as Space
import UI.Typography as Typography


type alias Props msg =
    { people : List Model.Mobber.Mobber
    , roles : List Role
    , onShuffle : msg
    , onRotate : msg
    , onSettings : msg
    , onAdd : msg
    }


view : Props msg -> Html.Html msg
view props =
    Column.column2
        [ Attr.css
            [ Css.paddingBottom <| Size.toElmCss Space.s
            , Css.width <| Css.pct 100
            , if List.isEmpty props.people then
                Css.borderBottom Css.zero

              else
                Css.borderBottom3 (Css.px 1) Css.solid (Color.toElmCss <| Palettes.monochrome.on.background)
            ]
        ]
        [ header props
        , displaySpecials props
        , separator props
        , displayRealMobbers props
        ]


header : Props msg -> Html.Html msg
header props =
    Row.row
        [ Attr.css
            [ UI.Css.gap Space.s
            , Css.alignItems Css.center
            , Css.borderBottom3 (Css.px 1) Css.solid (Color.toElmCss <| Palettes.monochrome.on.background)
            , Css.paddingBottom <| Size.toElmCss Space.xs
            , Css.marginBottom <| Size.toElmCss Space.s
            ]
        ]
        [ Html.h3
            [ Attr.css
                [ Css.margin Css.zero
                , Css.flexGrow <| Css.num 1
                , Css.fontWeight Css.normal
                ]
            ]
            [ Html.text "Mobbers" ]
        , UI.Button.Link.view [ Attr.title "Add" ]
            { text =
                UI.Icons.Ion.plus
                    { size = Typography.m
                    , color = Palettes.monochrome.on.background
                    }
            , onClick = props.onAdd
            }
        , UI.Button.Link.view [ Attr.title "Shuffle" ]
            { text =
                UI.Icons.Ion.shuffle
                    { size = Typography.m
                    , color = Palettes.monochrome.on.background
                    }
            , onClick = props.onShuffle
            }
        , UI.Button.Link.view [ Attr.title "Rotate" ]
            { text =
                UI.Icons.Ion.rotate
                    { size = Typography.m
                    , color = Palettes.monochrome.on.background
                    }
            , onClick = props.onRotate
            }
        , UI.Button.Link.view [ Attr.css [ Css.transform <| Css.translateY <| Css.px 1 ] ]
            { text =
                UI.Icons.Ion.settings
                    { size = Typography.m
                    , color = Palettes.monochrome.on.background
                    }
            , onClick = props.onSettings
            }
        ]


separator : Props msg -> Html.Html msg
separator props =
    if List.isEmpty props.roles || List.length props.people <= List.length props.roles then
        none

    else
        Html.hr
            [ Attr.css
                [ Css.border Css.zero
                , Css.borderTop3 (Css.px 1) Css.dashed <| Color.toElmCss <| Palettes.monochrome.on.background
                , Css.width <| Css.pct 100
                ]
            ]
            []



-- With Role


displaySpecials : Props msg -> Html.Html msg
displaySpecials props =
    Row.row
        [ Attr.css
            [ Css.justifyContent Css.spaceBetween
            , Css.flexWrap Css.wrap
            , UI.Css.gap Space.m
            ]
        ]
        (props.people
            |> Lib.ListExtras.zip props.roles
            |> List.map
                (\( role, mobber ) ->
                    displayMobber
                        { role = Just role
                        , mobber = mobber
                        , emphasis = True
                        }
                )
        )



-- Mobbers


displayRealMobbers : Props msg -> Html.Html msg
displayRealMobbers props =
    case props.people |> List.drop (List.length props.roles) of
        nextUp :: mobbers ->
            let
                lastSpecialRole =
                    props.roles |> List.reverse |> List.head
            in
            Row.row
                [ Attr.css
                    [ Css.justifyContent Css.spaceBetween
                    , Css.alignItems Css.flexEnd
                    , Css.flexWrap Css.wrap
                    , UI.Css.gap Space.s
                    ]
                ]
                (displayMobber
                    { role = lastSpecialRole |> Maybe.map Role.toNextUp
                    , mobber = nextUp
                    , emphasis = False
                    }
                    :: (mobbers
                            |> List.map
                                (\mobber ->
                                    displayMobber
                                        { role = Nothing
                                        , mobber = mobber
                                        , emphasis = False
                                        }
                                )
                       )
                )

        _ ->
            Html.span [] []



-- Mobber


displayMobber :
    { role : Maybe Role
    , mobber : Model.Mobber.Mobber
    , emphasis : Bool
    }
    -> Html.Html msg
displayMobber { role, mobber, emphasis } =
    Row.row
        [ Attr.css
            [ Css.alignItems Css.center
            , UI.Css.gap <| Size.rem 0.7
            , Css.maxWidth <| Css.pct 100
            ]
        ]
        [ role
            |> Maybe.andThen iconForRole
            |> Maybe.map
                (\icon ->
                    Html.div [ Attr.css [ Css.flexShrink Css.zero, Css.height <| Css.rem 3 ] ]
                        [ icon
                            { size = Size.rem 3
                            , color = Palettes.monochrome.on.background
                            }
                        ]
                )
            |> Maybe.withDefault none
        , Html.div [ Attr.css [ Css.overflow Css.hidden ] ]
            [ role |> Maybe.map displayRoleName |> Maybe.withDefault none
            , Html.div
                [ Attr.css <|
                    ((if emphasis then
                        [ Typography.fontSize Typography.l
                        , Css.fontWeight Css.bold
                        ]

                      else
                        []
                     )
                        ++ [ Css.overflow Css.hidden
                           , Css.textOverflow Css.ellipsis
                           ]
                    )
                ]
                [ Html.text <| Lib.StringExtra.capitalize mobber.name ]
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


displayRoleName : Role -> Html.Html msg
displayRoleName lastSpecialRole =
    Html.div
        [ Attr.css [ Typography.fontSize Typography.s, Css.fontWeight Css.lighter ] ]
        [ Html.text <| Role.print lastSpecialRole
        ]


none : Html.Html msg
none =
    Html.span [ Attr.css [ Css.display Css.none ] ] []
