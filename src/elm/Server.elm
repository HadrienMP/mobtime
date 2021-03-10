module Server exposing (..)

import Set exposing (Set)


main : Program () Model Msg
main =
    Platform.worker
        { init = init
        , update = update
        , subscriptions = subscriptions
        }

type alias Event = String

type Msg
    = Received Event


type alias Model = { history : Set Event }

init : () -> (Model, Cmd Msg)
init _ =
    ({history = Set.empty}, Cmd.none)
