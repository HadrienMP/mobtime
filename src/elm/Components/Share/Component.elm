port module Components.Share.Component exposing (..)

import Components.Share.Button
import Components.Share.Modal
import Effect exposing (Effect)
import Html.Styled exposing (Html)
import Shared exposing (Shared)
import UI.Modal
import UI.Palettes
import Url


port copyToClipboard : String -> Cmd msg


type alias Model =
    { modalOpened : Bool }


type Msg
    = OpenModal
    | Copy String


update : Shared -> Msg -> Model -> ( Model, Effect Shared.Msg Msg )
update _ msg model =
    case msg of
        OpenModal ->
            ( { model | modalOpened = True }, Effect.none )

        Copy text ->
            ( model, Effect.fromCmd <| copyToClipboard <| text )


view : Shared -> Model -> { button : Html Msg, modal : Maybe (Html Msg) }
view shared model =
    { button =
        Components.Share.Button.view
            { onClick = OpenModal
            , color = UI.Palettes.monochrome.on.surface
            }
    , modal =
        if model.modalOpened then
            Just <|
                UI.Modal.withContent <|
                    Components.Share.Modal.view
                        { url = shared.url |> Url.toString
                        , copy = Copy
                        }

        else
            Nothing
    }
