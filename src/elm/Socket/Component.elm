module Socket.Component exposing (..)

import Html.Styled as Html exposing (Html)
import Html.Styled.Attributes as Attr
import UI.Color exposing (RGBA255)
import UI.Icons.Plugs
import UI.Rem exposing (Rem(..))


type alias Props =
    { socketConnected : Bool, color : RGBA255 }


display : List (Html.Attribute msg) -> Props -> Html msg
display attributes props =
    let
        ( icon, title ) =
            if props.socketConnected then
                ( UI.Icons.Plugs.on, "Connected to the server" )

            else
                ( UI.Icons.Plugs.off, "Disconnected, attempting to reconnect" )
    in
    Html.div (Attr.title title :: attributes)
        [ icon
            { height = Rem 1.2
            , color = props.color
            }
        ]
