module Tools exposing (..)

import Http exposing (Error(..))
import Random
import Uuid


uuid : Random.Generator String
uuid = Random.map Uuid.toString Uuid.uuidGenerator

fold : (error -> out) -> (success -> out) ->  Result error success -> out
fold errorF successF result =
    case result of
        Err error -> errorF error
        Ok success -> successF success

httpErrorToString : Http.Error -> String
httpErrorToString error =
    case error of
        BadUrl msg -> msg
        Timeout -> "timeout"
        NetworkError -> "network error"
        BadStatus _ -> "Bad status"
        BadBody msg -> msg