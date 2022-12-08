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
import UI.Row


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
button attributes { content, action, size, variant } =
    Html.button
        (Attr.css
            ([ Css.borderRadius <| Css.rem 0.2
             , Css.display Css.block
             ]
                ++ sizeStyles size
                ++ variantStyles variant
            )
            :: attributes
            ++ actionAttributes action
        )
        (case content of
            Icon icon ->
                [ icon { size = UI.Rem.Rem 1, color = UI.Palettes.monochrome.on.surface } ]

            Text text ->
                [ Html.text text ]

            Both { icon, text } ->
                [ UI.Row.row
                    [ Attr.css
                        [ Css.justifyContent Css.center
                        , Css.alignItems Css.center
                        ]
                    ]
                    [ UI.Row.Gap <| iconTextGap size ]
                    [ icon { size = UI.Rem.Rem 1, color = UI.Palettes.monochrome.on.surface }
                    , Html.text text
                    ]
                ]
        )


variantStyles : Variant -> List Css.Style
variantStyles variant =
    case variant of
        Primary ->
            [ Css.backgroundColor <| UI.Color.toElmCss <| UI.Palettes.monochrome.surface
            ]

        Secondary ->
            [ Css.backgroundColor <| UI.Color.toElmCss <| UI.Color.fromHex "#555"
            ]


sizeStyles : Size -> List Css.Style
sizeStyles size =
    case size of
        S ->
            [ Css.padding <| Css.rem 0.4
            , Css.fontSize <| Css.rem 0.8
            ]

        M ->
            [ Css.padding <| Css.rem 0.6
            , Css.fontSize <| Css.rem 1
            ]

        L ->
            [ Css.padding <| Css.rem 1.2
            , Css.fontSize <| Css.rem 1.2
            ]


iconTextGap : Size -> UI.Rem.Rem
iconTextGap size =
    case size of
        S ->
            UI.Rem.Rem 0.4

        M ->
            UI.Rem.Rem 0.6

        L ->
            UI.Rem.Rem 0.8


actionAttributes : Action msg -> List (Html.Attribute msg)
actionAttributes action =
    case action of
        OnPress onPress ->
            [ onPress |> Maybe.map onClick |> Maybe.withDefault (Attr.property "" Json.Encode.null)
            , Attr.type_ "button"
            ]

        Submit ->
            [ Attr.type_ "submit" ]
