module Pages.Mob.Mobbers.PageView exposing (Props, view)

import Components.Form.Input.View
import Components.Mobbers.View
import Components.SecondaryPage.View
import Css
import Html.Styled as Html
import Html.Styled.Attributes as Attr
import Html.Styled.Events as Evts
import Lib.ListExtras
import Model.MobName exposing (MobName)
import Model.Mobber
import Model.Role
import UI.Button.View
import UI.Column as Column
import UI.Css
import UI.Icons.Ion
import UI.Palettes as Palettes
import UI.Row as Row
import UI.Size as Size
import UI.Space as Space


type alias Props msg =
    { people : List Model.Mobber.Mobber
    , roles : List Model.Role.Role
    , onShuffle : msg
    , onRotate : msg
    , onDelete : Model.Mobber.Mobber -> msg
    , onBack : msg
    , mob : MobName
    , input : { value : String, onChange : String -> msg, onSubmit : msg }
    }


view : Props msg -> Html.Html msg
view props =
    Components.SecondaryPage.View.view
        { onBack = props.onBack
        , title = "Mobbers"
        , content =
            Column.column2
                [ Attr.css [ UI.Css.gap Space.s ] ]
                [ form props
                , viewMobbers props
                ]
        }


form : Props msg -> Html.Html msg
form props =
    Html.form
        [ Evts.onSubmit props.input.onSubmit
        , Attr.css
            [ Css.displayFlex
            , UI.Css.gap <| Space.s
            , Css.alignItems Css.flexEnd
            ]
        ]
        [ Components.Form.Input.View.view
            [ Attr.css [ Css.flexGrow <| Css.num 1 ]
            ]
            { id = "mobber-name"
            , label = "Name"
            , value = props.input.value
            , onChange = props.input.onChange
            , required = True
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
        [ Row.row
            [ Attr.css
                [ UI.Css.gap Space.s
                , Css.justifyContent Css.right
                ]
            ]
            [ UI.Button.View.button []
                { content = UI.Button.View.Both { icon = UI.Icons.Ion.shuffle, text = "Shuffle" }
                , variant = UI.Button.View.Primary
                , action = UI.Button.View.OnPress <| Just props.onShuffle
                , size = UI.Button.View.S
                }
            , UI.Button.View.button []
                { content = UI.Button.View.Both { icon = UI.Icons.Ion.rotate, text = "Rotate" }
                , variant = UI.Button.View.Primary
                , action = UI.Button.View.OnPress <| Just props.onRotate
                , size = UI.Button.View.S
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
    Row.row
        [ Attr.css
            [ Css.alignItems Css.center
            , UI.Css.gap <| Size.rem 1
            , Css.borderTop2 (Css.px 1) Css.solid
            , Css.padding2 (Size.toElmCss Space.xs) Css.zero
            ]
        ]
        [ role
            |> Maybe.andThen
                Components.Mobbers.View.iconForRole
            |> Maybe.map
                (\icon ->
                    icon
                        { size = Size.rem 2
                        , color = Palettes.monochrome.on.background
                        }
                )
            |> Maybe.withDefault (Html.div [ Attr.css [ Css.height <| Css.rem 2, Css.width <| Css.rem 2 ] ] [])
            |> List.singleton
            |> Html.span [ Attr.css [ Css.flexShrink Css.zero ] ]
        , Html.span
            [ Attr.css
                [ Css.flexGrow <| Css.num 1
                , Css.overflow Css.hidden
                , Css.textOverflow Css.ellipsis
                ]
            , Attr.title mobber.name
            ]
            [ Html.text mobber.name ]
        , Html.span
            [ Attr.css
                [ Css.cursor Css.pointer
                ]
            , Evts.onClick <| onDelete mobber
            , Attr.title "Delete"
            ]
            [ UI.Icons.Ion.delete { size = Size.rem 1, color = Palettes.monochrome.on.background } ]
        ]
