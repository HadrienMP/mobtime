module Server exposing (..)


main : Program () Model Msg
main =
    Platform.worker
        { init = init
        , update = update
        , subscriptions = subscriptions
        }

type Msg
    = Received


type alias Model = { }

init : () -> (Model, Cmd Msg)
init _ =
    ({}, Cmd.none)

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    (model, Cmd.none)

subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
