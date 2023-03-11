module UI.Row exposing (row)

import Css
import Html.Styled as Html
import Html.Styled.Attributes as Attr


row :
    List (Html.Attribute msg)
    -> List (Html.Html msg)
    -> Html.Html msg
row attr children =
    Html.div
        (Attr.css [ Css.displayFlex ] :: attr)
        children
