port module Socket.Socket exposing (..)

import Css
import Html.Styled as Html
import Lib.Duration
import Model.MobName exposing (MobName)
import Socket.Component
import UI.Color exposing (RGBA255)
import UI.Space


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


socketId : Model -> Maybe SocketId
socketId model =
    case model of
        On id ->
            Just id

        _ ->
            Nothing



-- Update


type Msg
    = Connected String
    | Disconnected


animationDuration =
    Lib.Duration.ofSeconds 1


update : Maybe MobName -> Msg -> Model -> ( Model, Cmd Msg )
update mob msg _ =
    case msg of
        Connected id ->
            ( On <| SocketId id
            , case mob of
                Just value ->
                    socketJoin <| Model.MobName.print value

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
    Socket.Component.display attributes
        { socketConnected = status /= Off
        , color = color
        }


common : List Css.Style
common =
    [ Css.position Css.fixed
    , Css.top <| UI.Space.s
    , Css.right <| UI.Space.s
    , Css.zIndex <| Css.int 1000
    ]
