port module Socket.Socket exposing (..)

import Css
import Html.Styled as Html
import Html.Styled.Attributes as Attr exposing (css)
import Lib.Duration
import Model.MobName exposing (MobName)
import UI.Animations
import UI.Elements
import UI.Palettes
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


view : List (Html.Attribute msg) -> Model -> Html.Html msg
view attributes status =
    case status of
        On _ ->
            Html.div
                (attributes
                    ++ [ css (common ++ UI.Animations.fadeIn animationDuration)
                       , Attr.title "Connected"
                       ]
                )
                [ UI.Elements.dot UI.Palettes.monochrome.success ]

        Off ->
            Html.div
                (attributes
                    ++ [ css (common ++ UI.Animations.blink)
                       , Attr.title "Disconnected from server, reconnecting"
                       ]
                )
                [ UI.Elements.dot UI.Palettes.monochrome.error ]


common : List Css.Style
common =
    [ Css.position Css.fixed
    , Css.top <| UI.Space.s
    , Css.right <| UI.Space.s
    , Css.zIndex <| Css.int 1000
    ]
