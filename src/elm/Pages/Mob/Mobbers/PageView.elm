module Pages.Mob.Mobbers.PageView exposing (Props, view)

import Components.Form.Input.View
import Components.Mobbers.Summary
import Css
import Html.Styled as Html
import Html.Styled.Attributes as Attr
import Html.Styled.Events as Evts
import Lib.ListExtras
import Model.Mobber
import Model.Role
import UI.Button.Link
import UI.Button.View
import UI.Column as Column
import UI.Css
import UI.Icons.Ion
import UI.Palettes as Palettes
import UI.Row as Row
import UI.Size as Size
import UI.Space as Space
import UI.Typography.Typography as Typography


type alias Props msg =
    { people : List Model.Mobber.Mobber
    , roles : List Model.Role.Role
    , onShuffle : msg
    , onRotate : msg
    , onDelete : Model.Mobber.Mobber -> msg
    , onAdd : String -> msg
    , input : { value : String, onChange : String -> msg, onSubmit : msg }
    }


view : Props msg -> Html.Html msg
view props =
    Column.column2
        [ Attr.css [ UI.Css.gap Space.s ] ]
        [ form props
        , viewMobbers props
        ]


form : Props msg -> Html.Html msg
form props =
    Html.form
        [ Evts.onSubmit props.input.onSubmit
        , Attr.css [ Css.displayFlex, UI.Css.gap <| Space.s ]
        ]
        [ Components.Form.Input.View.view
            [ Attr.css [ Css.flexGrow <| Css.num 1 ]
            ]
            { id = "mobber-name"
            , label = "Name"
            , value = props.input.value
            , onChange = props.input.onChange
            }
        , UI.Button.View.button []
            { content =
                UI.Button.View.Both
                    { icon = UI.Icons.Ion.plus
                    , text = "Add"
                    }
            , action = UI.Button.View.Submit
            , variant = UI.Button.View.Primary
            , size = UI.Button.View.M
            }
        ]


viewMobbers : Props msg -> Html.Html msg
viewMobbers props =
    let
        withRoles =
            props.people |> Lib.ListExtras.zip props.roles

        withoutRoles =
            props.people |> List.drop (List.length props.roles)
    in
    Column.column2
        [ Attr.css [ UI.Css.gap Space.xs ] ]
        [ Row.row2
            [ Attr.css
                [ UI.Css.gap Space.s
                , Css.justifyContent Css.right
                ]
            ]
            [ UI.Button.Link.view [ Attr.css [ Typography.fontSize Typography.s ] ]
                { text = Html.span [] [ Html.text "Shuffle" ]
                , onClick = props.onShuffle
                }
            , UI.Button.Link.view [ Attr.css [ Typography.fontSize Typography.s ] ]
                { text = Html.text "Rotate"
                , onClick = props.onRotate
                }
            ]
        , Column.column2
            []
            ((withRoles
                |> List.map
                    (\( role, mobber ) ->
                        displayMobber
                            { role = Just role
                            , mobber = mobber
                            , onDelete = props.onDelete
                            }
                    )
             )
                ++ (withoutRoles
                        |> List.map
                            (\mobber ->
                                displayMobber
                                    { role = Nothing
                                    , mobber = mobber
                                    , onDelete = props.onDelete
                                    }
                            )
                   )
            )
        ]


displayMobber : { role : Maybe Model.Role.Role, mobber : Model.Mobber.Mobber, onDelete : Model.Mobber.Mobber -> msg } -> Html.Html msg
displayMobber { role, mobber, onDelete } =
    Row.row2
        [ Attr.css
            [ Css.alignItems Css.center
            , Css.lineHeight <| Css.num 1
            , UI.Css.gap <| Size.rem 1
            , Css.borderTop2 (Css.px 1) Css.solid
            ]
        ]
        [ role
            |> Maybe.andThen
                Components.Mobbers.Summary.iconForRole
            |> Maybe.map
                (\icon ->
                    icon
                        { size = Size.rem 2
                        , color = Palettes.monochrome.on.background
                        }
                )
            |> Maybe.withDefault (Html.span [ Attr.css [ Css.height <| Css.rem 2, Css.width <| Css.rem 2 ] ] [])
        , Html.span [ Attr.css [ Css.flexGrow <| Css.num 1 ] ] [ Html.text mobber.name ]
        , Html.span
            [ Attr.css
                [ Css.cursor Css.pointer
                ]
            , Evts.onClick <| onDelete mobber
            , Attr.title "Delete"
            ]
            [ UI.Icons.Ion.delete { size = Size.rem 1, color = Palettes.monochrome.on.background } ]
        ]
