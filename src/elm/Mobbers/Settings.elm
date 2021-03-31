module Mobbers.Settings exposing (..)

import Field
import Field.String
import Html exposing (Html, button, div, form, input, li, p, text, ul)
import Html.Attributes as Attributes exposing (class, disabled, id, placeholder, type_, value)
import Html.Events exposing (onClick, onInput, onSubmit)
import Lib.Icons.Ion as Icons
import Lib.ListExtras exposing (assign)
import Lib.Toaster exposing (Level(..), Toast, Toasts)
import Mobbers.Mobbers as Mobbers exposing (Mobbers)
import Mobbers.Mobber exposing (Mobber)
import Random
import Random.List
import SharedEvents
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
    | ShareEvent SharedEvents.Event


type alias UpdateResult =
    { updated : Model
    , command : Cmd Msg
    , toasts : Toasts
    }


update : Msg -> Mobbers -> Model -> UpdateResult
update msg mobbers model =
    case msg of
        NameChanged name ->
            { updated = { model | mobberName = name |> Field.resetValue model.mobberName |> Field.String.notEmpty }
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
                    { updated = { model | mobberName = Field.init "" }
                    , command =
                        Random.generate (\id -> Add <| Mobber id validMobberName) Uuid.uuidGenerator
                    , toasts = []
                    }

                Err _ ->
                    { updated = { model | mobberName = name }
                    , command = Cmd.none
                    , toasts = [ Toast Error "The mobber name cannot be empty" ]
                    }

        Add mobber ->
            { updated = model
            , command =
                mobber
                    |> SharedEvents.AddedMobber
                    |> SharedEvents.toJson
                    |> SharedEvents.sendEvent
            , toasts = []
            }

        Shuffle ->
            { updated = model
            , command = Random.generate (ShareEvent << SharedEvents.ShuffledMobbers) <| Mobbers.shuffle mobbers
            , toasts = []
            }

        ShareEvent event ->
            -- TODO duplicated code
            { updated = model
            , command =
                event
                    |> SharedEvents.toJson
                    |> SharedEvents.sendEvent
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
                , onClick <| ShareEvent <| SharedEvents.RotatedMobbers
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
            (assignRoles mobbers
                |> List.map mobberView
                |> List.filter ((/=) Nothing)
                |> List.map (Maybe.withDefault (li [] []))
            )
        ]


assignRoles : Mobbers -> List ( Maybe String, Maybe Mobber )
assignRoles mobbers =
    assign [ "Driver", "Navigator" ] <| Mobbers.toList mobbers


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


mobberView : ( Maybe String, Maybe Mobber ) -> Maybe (Html Msg)
mobberView ( role, maybeMobber ) =
    maybeMobber
        |> Maybe.map
            (\mobber ->
                li []
                    [ p [] [ text <| Maybe.withDefault "Mobber" role ]
                    , div
                        []
                        [ input [ type_ "text", value mobber.name ] []
                        , button
                            [ onClick <| ShareEvent <| SharedEvents.DeletedMobber mobber ]
                            [ Icons.delete ]
                        ]
                    ]
            )
