port module UserPreferences exposing (..)

import Components.Form.Volume.Field as Volume
import Components.Form.Volume.Type as Volume
import Json.Decode as Decode
import Json.Encode as Json


port savePreferences : Json.Value -> Cmd msg



-- Type


type alias Model =
    { volume : Volume.Volume
    , displaySeconds : Bool
    , useP2P : Bool
    }


default : Model
default =
    { volume = Volume.default
    , displaySeconds = False
    , useP2P = False
    }



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
        [ ( "volume", Volume.encode model.volume )
        , ( "displaySeconds", Json.bool model.displaySeconds )
        , ( "useP2P", Json.bool model.useP2P )
        ]


decode : Decode.Value -> Model
decode json =
    Decode.decodeValue decoder json |> Result.withDefault default


decoder : Decode.Decoder Model
decoder =
    Decode.map3 Model
        (Decode.field "volume" Volume.decoder)
        (Decode.field "displaySeconds" Decode.bool)
        (Decode.field "useP2P" Decode.bool)



-- Update


type Msg
    = VolumeMsg Volume.Msg
    | ToggleSeconds
    | ToggleP2P


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        ( updated, command ) =
            case msg of
                VolumeMsg subMsg ->
                    Volume.update subMsg model.volume
                        |> Tuple.mapBoth
                            (\a -> { model | volume = a })
                            (Cmd.map VolumeMsg)

                ToggleSeconds ->
                    ( { model | displaySeconds = not model.displaySeconds }, Cmd.none )

                ToggleP2P ->
                    ( { model | useP2P = not model.useP2P }, Cmd.none )
    in
    ( updated, Cmd.batch [ command, updated |> encode |> savePreferences ] )
