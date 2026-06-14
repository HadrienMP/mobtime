port module Components.Socket.Socket exposing (Model, Msg(..), init, joinRoom, subscriptions, update, view)

import Components.Socket.View exposing (SocketStatus(..))
import Html.Styled as Html
import UI.Color exposing (RGBA255)


port socketStatusChange : (String -> msg) -> Sub msg


port socketJoin : String -> Cmd msg


joinRoom : String -> Cmd msg
joinRoom =
    socketJoin



-- Init


type alias Model =
    SocketStatus


init : ( Model, Cmd Msg )
init =
    ( Disconnected, Cmd.none )



-- Update


type Msg
    = GotStatusChange String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotStatusChange "connected" ->
            ( Connected
            , Cmd.none
            )

        GotStatusChange "disconnected" ->
            ( Disconnected, Cmd.none )

        GotStatusChange "connecting" ->
            ( Connecting, Cmd.none )

        GotStatusChange _ ->
            ( model, Cmd.none )



-- Subscriptions


subscriptions : Model -> Sub Msg
subscriptions _ =
    socketStatusChange GotStatusChange



-- View


view : List (Html.Attribute msg) -> RGBA255 -> Model -> Html.Html msg
view attributes color status =
    Components.Socket.View.view attributes
        { status = status
        , color = color
        }
