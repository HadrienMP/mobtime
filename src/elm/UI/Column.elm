module UI.Column exposing (..)

import Css
import Html.Styled as Html exposing (Html)
import Html.Styled.Attributes as Attr
import UI.Rem


type ColumnAttribute
    = Gap UI.Rem.Rem
    | Padding UI.Rem.Rem


column :
    List (Html.Attribute msg)
    -> List ColumnAttribute
    -> List (Html.Html msg)
    -> Html.Html msg
column htmlAttr colAttr children =
    Html.div
        ((Attr.css <|
            [ Css.displayFlex
            , Css.flexDirection Css.column
            ]
                ++ (colAttr |> List.map toStyle |> List.foldl (++) [])
         )
            :: htmlAttr
        )
        children


twoColumns : { left : Css.Pct, right : Css.Pct } -> ( Html msg, Html msg ) -> Html msg
twoColumns size ( left, right ) =
    column []
        []
        [ Html.div [ Attr.css [ Css.width size.left ] ] [ left ]
        , Html.div [ Attr.css [ Css.width size.right ] ] [ right ]
        ]


toStyle : ColumnAttribute -> List Css.Style
toStyle attr =
    case attr of
        Gap rem ->
            [ Css.property "gap" <| UI.Rem.toCssString rem ]

        Padding rem ->
            [ Css.padding <| UI.Rem.toElmCss rem ]
