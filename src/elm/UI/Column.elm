module UI.Column exposing (..)

import Css
import Html.Styled as Html
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


toStyle : ColumnAttribute -> List Css.Style
toStyle attr =
    case attr of
        Gap rem ->
            [ Css.property "gap" <| UI.Rem.toCssString rem ]

        Padding rem ->
            [ Css.padding <| UI.Rem.toElmCss rem ]
