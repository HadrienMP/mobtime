module UI.Buttons exposing (..)

import Css
import Html.Styled as Html exposing (Html)
import Html.Styled.Attributes as Attr
import Html.Styled.Events exposing (onClick)
import Json.Encode
import UI.Color
import UI.Icons.Common
import UI.Palettes
import UI.Rem


type Content msg
    = Icon (UI.Icons.Common.Icon msg)
    | Text String
    | Both
        { icon : UI.Icons.Common.Icon msg
        , text : String
        }


type Action msg
    = OnPress (Maybe msg)
    | Submit


type Variant
    = Primary
    | Secondary


type Size
    = S
    | M
    | L


button :
    List (Html.Attribute msg)
    ->
        { content : Content msg
        , variant : Variant
        , size : Size
        , action : Action msg
        }
    -> Html msg
button attributes { content, action } =
    Html.button
        (Attr.css
            [ Css.borderRadius <| Css.rem 0.2
            , Css.padding <| Css.rem 0.6
            , Css.backgroundColor <| UI.Color.toElmCss <| UI.Color.black
            , Css.hover [ Css.backgroundColor <| UI.Color.toElmCss <| UI.Color.black ]
            ]
            :: actionAttribute action
            :: attributes
        )
        (case content of
            Icon icon ->
                [ icon { size = UI.Rem.Rem 1, color = UI.Palettes.monochrome.on.surface } ]

            Text text ->
                [ Html.text text ]

            Both { icon, text } ->
                [ Html.div
                    [ Attr.css
                        [ Css.displayFlex
                        , Css.alignItems Css.center
                        , Css.fontSize <| Css.rem 1.1
                        ]
                    ]
                    [ icon { size = UI.Rem.Rem 1, color = UI.Palettes.monochrome.on.surface }
                    , Html.div
                        [ Attr.css
                            [ Css.paddingLeft <| Css.rem 0.6
                            ]
                        ]
                        [ Html.text text ]
                    ]
                ]
        )


actionAttribute : Action msg -> Html.Attribute msg
actionAttribute action =
    case action of
        OnPress onPress ->
            onPress |> Maybe.map onClick |> Maybe.withDefault (Attr.property "" Json.Encode.null)

        Submit ->
            Attr.type_ "submit"
