module UI.Column exposing (ColumnAttribute(..), column)

import Css
import Html.Styled as Html exposing (Html)
import Html.Styled.Attributes as Attr
import UI.Rem as Rem


type ColumnAttribute
    = Gap Rem.Rem


column :
    List (Html.Attribute msg)
    -> List ColumnAttribute
    -> List (Html msg)
    -> Html msg
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
            [ Css.property "gap" <| Rem.toCssString rem ]
