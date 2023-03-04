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
import UI.Rem as Rem
import UI.Row as Row


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
                [ icon { size = iconSize size, color = Palettes.monochrome.on.surface } ]

            Text text ->
                [ Html.text text ]

            Both { icon, text } ->
                [ Row.row
                    [ Attr.css
                        [ Css.justifyContent Css.center
                        , Css.alignItems Css.center
                        ]
                    ]
                    [ Row.Gap <| iconTextGap size ]
                    [ icon { size = iconSize size, color = Palettes.monochrome.on.surface }
                    , Html.text text
                    ]
                ]
        )


iconSize : Size -> Rem.Rem
iconSize size =
    Rem.Rem <|
        case size of
            S ->
                1.8

            M ->
                2.5

            L ->
                3.6


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
    case size of
        S ->
            [ Css.padding <| Css.rem 0.4
            , Css.fontSize <| Css.rem 0.8
            ]

        M ->
            [ Css.padding <| Css.rem 0.6
            , Css.fontSize <| Css.rem 1.2
            ]

        L ->
            [ Css.padding <| Css.rem 1.2
            , Css.fontSize <| Css.rem 1.6
            ]


iconTextGap : Size -> Rem.Rem
iconTextGap size =
    case size of
        S ->
            Rem.Rem 0.4

        M ->
            Rem.Rem 0.6

        L ->
            Rem.Rem 0.8


actionAttributes : Action msg -> List (Html.Attribute msg)
actionAttributes action =
    case action of
        OnPress onPress ->
            [ onPress |> Maybe.map onClick |> Maybe.withDefault (Attr.property "" Json.null)
            , Attr.type_ "button"
            ]

        Submit ->
            [ Attr.type_ "submit" ]
