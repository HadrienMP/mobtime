module UserPreferences exposing (..)

import Json.Encode


type alias Model =
    { volume : Int }


default : Model
default =
    { volume = 50 }


encode : Model -> Json.Encode.Value
encode model =
    Json.Encode.object
        [ ( "volume", Json.Encode.int model.volume ) ]
