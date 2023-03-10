module UI.Row exposing (RowAttribute(..), row, row2)

import Css
import Html.Styled as Html
import Html.Styled.Attributes as Attr
import UI.Size as Size


type RowAttribute
    = Gap Size.Size


row :
    List (Html.Attribute msg)
    -> List RowAttribute
    -> List (Html.Html msg)
    -> Html.Html msg
row htmlAttr attr children =
    Html.div
        ((Attr.css <|
            Css.displayFlex
                :: (attr |> List.map toStyle |> List.foldl (++) [])
         )
            :: htmlAttr
        )
        children


row2 :
    List (Html.Attribute msg)
    -> List (Html.Html msg)
    -> Html.Html msg
row2 attr children =
    Html.div
        (Attr.css [ Css.displayFlex ] :: attr)
        children


toStyle : RowAttribute -> List Css.Style
toStyle attr =
    case attr of
        Gap rem ->
            [ Css.property "gap" <| Size.toCssString rem ]
