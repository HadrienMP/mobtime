module UI.Row exposing (RowAttribute(..), row)

import Css
import Html.Styled as Html
import Html.Styled.Attributes as Attr
import UI.Rem


type RowAttribute
    = Gap UI.Rem.Rem
    | Padding UI.Rem.Rem


row :
    List (Html.Attribute msg)
    -> List RowAttribute
    -> List (Html.Html msg)
    -> Html.Html msg
row htmlAttr colAttr children =
    Html.div
        ((Attr.css <|
            Css.displayFlex
                :: (colAttr |> List.map toStyle |> List.foldl (++) [])
         )
            :: htmlAttr
        )
        children


toStyle : RowAttribute -> List Css.Style
toStyle attr =
    case attr of
        Gap rem ->
            [ Css.property "gap" <| UI.Rem.toCssString rem ]

        Padding rem ->
            [ Css.padding <| UI.Rem.toElmCss rem ]
