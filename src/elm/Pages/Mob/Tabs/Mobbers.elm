module Pages.Mob.Tabs.Mobbers exposing (..)

import Field
import Field.String
import Html exposing (Html, button, div, form, input, li, p, text, ul)
import Html.Attributes as Attributes exposing (class, disabled, id, placeholder, type_)
import Html.Events exposing (onClick, onInput, onSubmit)
import Lib.Icons.Ion as Icons
import Lib.Toaster as Toaster
import Lib.UpdateResult exposing (UpdateResult)
import Model.MobName exposing (MobName)
import Model.Mobber exposing (Mobber)
import Model.Mobbers as Mobbers exposing (Mobbers)
import Model.Events
import Random
import Uuid


type alias Model =
    { mobberName : Field.String.Field }


init : Model
init =
    { mobberName = Field.init "" }



-- UPDATE


type Msg
    = NameChanged String
    | StartAdding
    | Add Mobber
    | Shuffle
    | ShareEvent Model.Events.Event


update : Msg -> Mobbers -> MobName -> Model -> UpdateResult Model Msg
update msg mobbers mob model =
    case msg of
        NameChanged name ->
            { model = { model | mobberName = name |> Field.resetValue model.mobberName |> Field.String.notEmpty }
            , command = Cmd.none
            , toasts = []
            }

        StartAdding ->
            let
                name =
                    model.mobberName |> Field.String.notEmpty
            in
            case Field.toResult name of
                Ok validMobberName ->
                    { model = { model | mobberName = Field.init "" }
                    , command =
                        Random.generate (\id -> Add <| Mobber id validMobberName) Uuid.uuidGenerator
                    , toasts = []
                    }

                Err _ ->
                    { model = { model | mobberName = name }
                    , command = Cmd.none
                    , toasts = [ Toaster.error "The mobber name cannot be empty" ]
                    }

        Add mobber ->
            { model = model
            , command =
                mobber
                    |> Model.Events.AddedMobber
                    |> Model.Events.MobEvent mob
                    |> Model.Events.mobEventToJson
                    |> Model.Events.sendEvent
            , toasts = []
            }

        Shuffle ->
            { model = model
            , command = Random.generate (ShareEvent << Model.Events.ShuffledMobbers) <| Mobbers.shuffle mobbers
            , toasts = []
            }

        ShareEvent event ->
            -- TODO duplicated code
            { model = model
            , command =
                event
                    |> Model.Events.MobEvent mob
                    |> Model.Events.mobEventToJson
                    |> Model.Events.sendEvent
            , toasts = []
            }



-- VIEW


view : Mobbers -> Model -> Html Msg
view mobbers model =
    div
        [ id "mobbers", class "tab" ]
        [ form
            [ id "add", onSubmit StartAdding ]
            [ Field.view (textFieldConfig "Mobber to be added" NameChanged) model.mobberName
            , button [ type_ "submit" ] [ Icons.plus ]
            ]
        , div [ class "button-row" ]
            [ button
                [ class "labelled-icon-button"
                , disabled (not <| Mobbers.rotatable mobbers)
                , onClick <| ShareEvent <| Model.Events.RotatedMobbers
                ]
                [ Icons.rotate
                , text "Rotate"
                ]
            , button
                [ class "labelled-icon-button"
                , disabled (not <| Mobbers.shufflable mobbers)
                , onClick Shuffle
                ]
                [ Icons.shuffle
                , text "Shuffle"
                ]
            ]
        , ul []
            (Mobbers.assignRoles mobbers
                |> List.map mobberView
            )
        ]


textFieldConfig : String -> (String -> msg) -> Field.String.ViewConfig msg
textFieldConfig title toMsg =
    { valid =
        \meta value ->
            div [ class "form-field" ]
                [ textInput title toMsg value meta ]
    , invalid =
        \meta value _ ->
            div [ class "form-field" ]
                [ textInput title toMsg value meta
                ]
    }


textInput : String -> (String -> msg) -> String -> { a | disabled : Bool } -> Html msg
textInput title toMsg value meta =
    input
        [ onInput toMsg
        , type_ "text"
        , placeholder title
        , Attributes.value value
        , disabled meta.disabled
        ]
        []


mobberView : ( String, Mobber ) -> Html Msg
mobberView ( role, mobber ) =
    li []
        [ p [ class "role" ] [ text role ]
        , div
            []
            [ p [ class "name" ] [ text mobber.name ]
            , button
                [ onClick <| ShareEvent <| Model.Events.DeletedMobber mobber ]
                [ Icons.delete ]
            ]
        ]
