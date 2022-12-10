module View exposing (..)

import Html.Styled as Html exposing (Html)


type alias View msg =
    { title : String
    , modal : Maybe (Html msg)
    , body : Html msg
    }


map : (a -> b) -> View a -> View b
map f view =
    { title = view.title
    , modal = Maybe.map (Html.map f) view.modal
    , body = Html.map f view.body
    }
