module UI.Button.View exposing (Action(..), Content(..), Size(..), Variant(..), button)

import Css
import Html.Styled as Html exposing (Html)
import Html.Styled.Attributes as Attr
import Html.Styled.Events exposing (onClick)
import Json.Encode as Json
import UI.Color as Color
import UI.Css
import UI.Icons.Common
import UI.Palettes as Palettes
import UI.Row as Row
import UI.Size as Size
import UI.Typography as Typography


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
    = XS
    | S
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
            ([ UI.Css.roundBorder
             , Css.display Css.block
             , Css.color <| Color.toElmCss <| Palettes.monochrome.on.surface
             , Css.cursor Css.pointer
             , Css.border Css.zero
             ]
                ++ sizeStyles size
                ++ variantStyles variant
            )
            :: attributes
            ++ actionAttributes action
        )
        (case content of
            Icon icon ->
                [ icon { size = getFontSize size, color = Palettes.monochrome.on.surface } ]

            Text text ->
                [ Html.text text ]

            Both { icon, text } ->
                [ Row.row
                    [ Attr.css
                        [ Css.justifyContent Css.center
                        , Css.alignItems Css.center
                        , UI.Css.gap <| iconTextGap size
                        ]
                    ]
                    [ icon { size = getFontSize size |> Size.multiplyBy 1.4, color = Palettes.monochrome.on.surface }
                    , Html.text text
                    ]
                ]
        )


getFontSize : Size -> Size.Size
getFontSize size =
    case size of
        XS ->
            Typography.xs

        S ->
            Typography.s

        M ->
            Typography.m

        L ->
            Typography.l


variantStyles : Variant -> List Css.Style
variantStyles variant =
    case variant of
        Primary ->
            [ Css.backgroundColor <| Color.toElmCss <| Palettes.monochrome.surface
            ]

        Secondary ->
            [ Css.backgroundColor <| Color.toElmCss <| Color.fromHex "#555"
            ]


sizeStyles : Size -> List Css.Style
sizeStyles size =
    let
        fontSize =
            getFontSize size

        paddingY =
            fontSize |> Size.multiplyBy 0.5

        paddingX =
            fontSize |> Size.multiplyBy 0.8
    in
    [ Typography.fontSize fontSize
    , Css.padding2 (Size.toElmCss paddingY) (Size.toElmCss paddingX)
    ]


iconTextGap : Size -> Size.Size
iconTextGap size =
    getFontSize size |> Size.multiplyBy 0.5


actionAttributes : Action msg -> List (Html.Attribute msg)
actionAttributes action =
    case action of
        OnPress onPress ->
            [ onPress |> Maybe.map onClick |> Maybe.withDefault (Attr.property "" Json.null)
            , Attr.type_ "button"
            ]

        Submit ->
            [ Attr.type_ "submit" ]
