module UserPreferences exposing (..)

import Json.Decode as Decode
import Json.Encode as Json
import Volume



-- Type


type alias Model =
    { volume : Volume.Volume }


default : Model
default =
    { volume = Volume.default }



-- Init


init : Decode.Value -> ( Model, Cmd msg )
init value =
    let
        preferences =
            decode value
    in
    ( preferences, Volume.change preferences.volume )



-- Json


encode : Model -> Json.Value
encode model =
    Json.object
        [ ( "volume", Volume.encode model.volume ) ]


decode : Decode.Value -> Model
decode json =
    Decode.decodeValue decoder json |> Result.withDefault default


decoder : Decode.Decoder Model
decoder =
    Decode.field "volume" Volume.decoder |> Decode.map Model
