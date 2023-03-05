module Components.NavBar.Component exposing (view)

import Components.NavBar.View
import Components.Socket.Socket
import Css
import Html.Styled as Html exposing (Html)
import Shared exposing (Shared)
import UI.Palettes as Palettes


view : List Css.Style -> Shared -> Html msg
view addedStyle shared =
    case shared.mob of
        Just mob ->
            Components.NavBar.View.view
                { mob = mob.name
                , socket = Components.Socket.Socket.view [] Palettes.monochrome.on.surface shared.socket
                , addedStyle = addedStyle
                }

        Nothing ->
            Html.span [] []
