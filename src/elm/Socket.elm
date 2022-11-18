port module Socket exposing (..)

import Css
import Html.Styled as Html
import Html.Styled.Attributes exposing (css)
import Lib.Delay
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
    | SwitchOff
    | SwitchOn SocketId


init : ( Model, Cmd Msg )
init =
    ( Off, Cmd.none )


socketId : Model -> Maybe SocketId
socketId model =
    case model of
        On id ->
            Just id

        SwitchOn id ->
            Just id

        _ ->
            Nothing



-- Update


type Msg
    = Connected String
    | Disconnected
    | Finished


update : Maybe MobName -> Msg -> Model -> ( Model, Cmd Msg )
update mob msg model =
    case msg of
        Connected id ->
            ( SwitchOn <| SocketId id
            , Cmd.batch
                [ Lib.Delay.after UI.Animations.fadeDuration Finished
                , case mob of
                    Just value ->
                        socketJoin <| Model.MobName.print value

                    Nothing ->
                        Cmd.none
                ]
            )

        Disconnected ->
            ( SwitchOff, Lib.Delay.after UI.Animations.fadeDuration Finished )

        Finished ->
            ( case model of
                SwitchOn id ->
                    On id

                SwitchOff ->
                    Off

                _ ->
                    model
            , Cmd.none
            )



-- Subscriptions


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ socketConnected Connected
        , socketDisconnected <| always Disconnected
        ]



-- View


view : Model -> Html.Html msg
view status =
    case status of
        SwitchOff ->
            Html.div
                [ css (common ++ UI.Animations.fadeOut) ]
                [ UI.Elements.dot UI.Palettes.monochrome.success ]

        SwitchOn _ ->
            Html.div
                [ css (common ++ UI.Animations.fadeOut) ]
                [ UI.Elements.dot UI.Palettes.monochrome.error ]

        On _ ->
            Html.div
                [ css (common ++ UI.Animations.fadeIn) ]
                [ UI.Elements.dot UI.Palettes.monochrome.success ]

        Off ->
            Html.div
                [ css (common ++ UI.Animations.blink) ]
                [ UI.Elements.dot UI.Palettes.monochrome.error ]


common : List Css.Style
common =
    [ Css.position Css.absolute
    , Css.top <| UI.Space.s
    , Css.right <| UI.Space.s
    ]
