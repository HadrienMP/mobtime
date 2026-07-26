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
import UI.Css
import UI.Icons.Captain
import UI.Icons.Common exposing (Icon)
import UI.Icons.Ion
import UI.Icons.Keyboard
import UI.Icons.Microphone
import UI.Palettes as Palettes
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
    Html.section
        [ Attr.id "team"
        , Attr.css
            [ Css.width <| Css.pct 70
            , if List.isEmpty props.people then
                Css.borderBottom Css.zero

              else
                Css.borderBottom3 (Css.px 1) Css.solid (Color.toElmCss <| Palettes.monochrome.on.background)
            ]
        ]
        [ header props
        , displayMobbersWithRoles props
        , displayOtherMobbers props
        ]


header : Props msg -> Html.Html msg
header props =
    Html.div
        [ Attr.css
            [ UI.Css.gap Space.s
            , Css.alignItems Css.center
            , Css.paddingBottom <| Size.toElmCss Space.xs
            , Css.borderBottom3 (Css.px 1) Css.solid (Color.toElmCss <| Palettes.monochrome.on.background)
            , Css.displayFlex
            ]
        ]
        [ Html.h3
            [ Attr.css
                [ Css.margin Css.zero
                , Css.flexGrow <| Css.num 1
                , Css.fontWeight Css.normal
                ]
            ]
            [ Html.text "Team" ]
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



-- With Role


displayMobbersWithRoles : Props msg -> Html.Html msg
displayMobbersWithRoles props =
    Html.div []
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


displayOtherMobbers : Props msg -> Html.Html msg
displayOtherMobbers props =
    case props.people |> List.drop (List.length props.roles) of
        nextUp :: mobbers ->
            let
                lastSpecialRole =
                    props.roles |> List.reverse |> List.head
            in
            Html.div []
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
    Html.div
        [ Attr.class "mobber"
        , Attr.css
            [ Css.alignItems Css.center
            , UI.Css.gap <| Size.rem 0.4
            , Css.maxWidth <| Css.pct 100
            , Css.displayFlex
            , Css.borderTop3 (Css.px 1) Css.solid (Color.toElmCss <| Color.fromHex "ccc")
            , Css.padding2 (Css.px 4) Css.zero
            ]
        ]
        [ Html.div
            [ Attr.class "avatar-wrapper"
            , Attr.css
                [ Css.height <|
                    Css.rem <|
                        if role == Nothing then
                            2

                        else
                            3
                , Css.property "aspect-ratio" "1"
                , Css.overflow Css.hidden
                ]
            ]
            [ Html.img
                [ Attr.src <| "https://api.dicebear.com/10.x/big-smile/svg?seed=" ++ mobber.name
                , Attr.alt "Avatar"
                , Attr.css []
                ]
                []
            ]
        , Html.div [ Attr.css [ Css.overflow Css.hidden ] ]
            [ Html.div
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
            , role |> Maybe.map displayRoleName |> Maybe.withDefault none
            ]
        ]


iconForRole : Role -> Maybe (Icon msg)
iconForRole role =
    case role.name of
        "Driver" ->
            Just UI.Icons.Keyboard.display

        "Navigator" ->
            Just UI.Icons.Captain.display

        "Translator" ->
            Just UI.Icons.Keyboard.display

        "Moderator" ->
            Just UI.Icons.Microphone.display

        _ ->
            Nothing


displayRoleName : Role -> Html.Html msg
displayRoleName lastSpecialRole =
    Html.div
        [ Attr.css
            [ Typography.fontSize Typography.s
            , Css.fontWeight Css.lighter
            , Css.displayFlex
            , Css.alignItems Css.center
            , Css.lineHeight <| Css.int 1
            , UI.Css.gap <| Size.px 6
            ]
        ]
        [ Html.text lastSpecialRole.name
        , case lastSpecialRole.description of
            Just description ->
                Html.span
                    [ Attr.title description ]
                    [ UI.Icons.Ion.questionMark { size = Size.rem 1, color = Color.black } ]

            Nothing ->
                Html.text ""
        ]


none : Html.Html msg
none =
    Html.span [ Attr.css [ Css.display Css.none ] ] []
