module UI.Column exposing (ColumnAttribute(..), column, column2)

import Css
import Html.Styled as Html exposing (Html)
import Html.Styled.Attributes as Attr
import UI.Size as Size


type ColumnAttribute
    = Gap Size.Size


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


column2 :
    List (Html.Attribute msg)
    -> List (Html msg)
    -> Html msg
column2 colAttr children =
    Html.div
        ((Attr.css <|
            [ Css.displayFlex
            , Css.flexDirection Css.column
            ]
         )
            :: colAttr
        )
        children


toStyle : ColumnAttribute -> List Css.Style
toStyle attr =
    case attr of
        Gap rem ->
            [ Css.property "gap" <| Size.toCssString rem ]
