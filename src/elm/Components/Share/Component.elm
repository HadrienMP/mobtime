port module Components.Share.Component exposing (..)

import Components.Share.Button
import Components.Share.Modal
import Effect exposing (Effect)
import Html.Styled exposing (Html, div)
import Lib.Toaster
import Shared exposing (Shared)
import UI.Modal.View
import UI.Palettes
import Url


port copyShareLink : String -> Cmd msg


port shareLinkCopied : (String -> msg) -> Sub msg


type alias Model =
    { modalOpened : Bool }


init : Model
init =
    { modalOpened = False }


type Msg
    = OpenModal
    | CloseModal
    | Copy String
    | Copied


update : Shared -> Msg -> Model -> ( Model, Effect Shared.Msg Msg )
update _ msg model =
    case msg of
        OpenModal ->
            ( { model | modalOpened = True }, Effect.none )

        CloseModal ->
            ( { model | modalOpened = False }, Effect.none )

        Copy text ->
            ( model, Effect.fromCmd <| copyShareLink <| text )

        Copied ->
            ( model, Shared.toast <| Lib.Toaster.success "The link has been copied to your clipboard" )


subscriptions : Model -> Sub Msg
subscriptions _ =
    shareLinkCopied <| always Copied


view : Shared -> Model -> Html Msg
view shared model =
    div []
        [ Components.Share.Button.view
            { onClick = OpenModal
            , color = UI.Palettes.monochrome.on.background
            }
        , if model.modalOpened then
            UI.Modal.View.view
                { onClose = CloseModal
                , content =
                    Components.Share.Modal.view
                        { url = shared.url |> Url.toString
                        , copy = Copy
                        }
                }

          else
            div [] []
        ]
