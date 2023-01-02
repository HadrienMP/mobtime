module Components.Socket.View exposing (..)

import Css
import Html.Styled as Html exposing (Html)
import Html.Styled.Attributes as Attr
import UI.Color exposing (RGBA255)
import UI.Icons.Plugs
import UI.Rem exposing (Rem(..))


type alias Props =
    { socketConnected : Bool, color : RGBA255 }


view : List (Html.Attribute msg) -> Props -> Html msg
view attributes props =
    let
        ( icon, title ) =
            if props.socketConnected then
                ( Nothing, "Connected to the server" )

            else
                ( Just UI.Icons.Plugs.off, "Disconnected, attempting to reconnect" )
    in
    icon
        |> Maybe.map
            (\it ->
                it
                    { height = Rem 1
                    , color = props.color
                    }
            )
        |> Maybe.withDefault (Html.div [ Attr.css [ Css.width <| Css.rem 1 ] ] [])
        |> List.singleton
        |> Html.div (Attr.title title :: attributes)
