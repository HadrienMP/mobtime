module View exposing (View, map)

import Html.Styled as Html exposing (Html)
import UI.Modal.View


type alias View msg =
    { title : String
    , modal : Maybe (UI.Modal.View.Modal msg)
    , body : Html msg
    }


map : (a -> b) -> View a -> View b
map f view =
    { title = view.title
    , modal = Maybe.map (UI.Modal.View.map f) view.modal
    , body = Html.map f view.body
    }
