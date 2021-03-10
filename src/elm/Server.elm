port module Server exposing (..)

import Json.Decode
import Json.Encode

port log: Json.Encode.Value -> Cmd msg
port receiveEvent : (Json.Encode.Value -> msg) -> Sub msg


main : Program () Model Msg
main =
    Platform.worker
        { init = init
        , update = update
        , subscriptions = subscriptions
        }


type Msg
    = Received Json.Decode.Value


type alias Model =
    {}


init : () -> ( Model, Cmd Msg )
init _ =
    ( {}, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Received value ->
            (model, log value)


subscriptions : Model -> Sub Msg
subscriptions model =
    receiveEvent Received
