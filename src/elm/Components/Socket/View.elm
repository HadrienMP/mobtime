module Components.Socket.View exposing (Props, SocketStatus(..), view)

import Css
import Html.Styled as Html exposing (Html)
import Html.Styled.Attributes as Attr
import UI.Color exposing (RGBA255)
import UI.Icons.Plugs
import UI.Size as Size


type SocketStatus
    = Connected
    | Connecting
    | Disconnected


type alias Props =
    { status : SocketStatus, color : RGBA255 }


view : List (Html.Attribute msg) -> Props -> Html msg
view attributes props =
    let
        ( icon, title ) =
            if props.status == Connected then
                ( Nothing, "Connected to the server" )

            else
                ( Just UI.Icons.Plugs.off, "Disconnected, attempting to reconnect" )
    in
    icon
        |> Maybe.map
            (\it ->
                it
                    { height = Size.rem 1
                    , color = props.color
                    }
            )
        |> Maybe.withDefault (Html.div [ Attr.css [ Css.width <| Css.rem 1 ] ] [])
        |> List.singleton
        |> Html.div (Attr.title title :: attributes)
