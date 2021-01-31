port module Main exposing (..)

import Browser
import Browser.Navigation as Nav
import Html exposing (h1, text)
import Json.Decode
import Json.Encode
import Url



-- MAIN


main : Program String Model Msg
main =
    Browser.document
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



--port messageReceiver : (( EventKind, Json.Decode.Value ) -> msg) -> Sub msg


port store : Json.Encode.Value -> Cmd msg



-- MODEL


type alias Model =
    String


init : String -> ( Model, Cmd Msg )
init flags =
    ( flags, Cmd.none )



-- UPDATE


type Msg
    = None


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        _ ->
            ( model, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : Model -> Browser.Document Msg
view _ =
    { title = "Mob Time !"
    , body =
        [ h1 [] [ text "Mob Time !" ] ]
    }
