port module Components.Socket.Socket exposing (Model(..), Msg(..), SocketId(..), init, joinRoom, subscriptions, update, view)

import Components.Socket.View
import Html.Styled as Html
import Model.Mob
import Model.MobName
import UI.Color exposing (RGBA255)


port socketConnected : (String -> msg) -> Sub msg


port socketDisconnected : ({} -> msg) -> Sub msg


port socketJoin : String -> Cmd msg


joinRoom : String -> Cmd msg
joinRoom =
    socketJoin



-- Init


type SocketId
    = SocketId String


type Model
    = On SocketId
    | Off


init : ( Model, Cmd Msg )
init =
    ( Off, Cmd.none )



-- Update


type Msg
    = Connected String
    | Disconnected


update : Maybe Model.Mob.Mob -> Msg -> Model -> ( Model, Cmd Msg )
update maybeMob msg _ =
    case msg of
        Connected id ->
            ( On <| SocketId id
            , case maybeMob of
                Just mob ->
                    socketJoin <| Model.MobName.print mob.name

                Nothing ->
                    Cmd.none
            )

        Disconnected ->
            ( Off, Cmd.none )



-- Subscriptions


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ socketConnected Connected
        , socketDisconnected <| always Disconnected
        ]



-- View


view : List (Html.Attribute msg) -> RGBA255 -> Model -> Html.Html msg
view attributes color status =
    Components.Socket.View.view attributes
        { socketConnected = status /= Off
        , color = color
        }
