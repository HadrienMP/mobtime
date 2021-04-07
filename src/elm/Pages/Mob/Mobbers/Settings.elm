module Pages.Mob.Mobbers.Settings exposing (..)

import Field
import Field.String
import Html exposing (Html, button, div, form, input, li, p, text, ul)
import Html.Attributes as Attributes exposing (class, disabled, id, placeholder, type_, value)
import Html.Events exposing (onClick, onInput, onSubmit)
import Lib.Icons.Ion as Icons
import Lib.ListExtras exposing (assign)
import Lib.Toaster exposing (Level(..), Toast, Toasts)
import Lib.UpdateResult exposing (UpdateResult)
import Pages.Mob.Mobbers.Mobbers as Mobbers exposing (Mobbers)
import Pages.Mob.Mobbers.Mobber exposing (Mobber)
import Pages.Mob.Name exposing (MobName)
import Random
import Random.List
import Peers.Events
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
    | ShareEvent Peers.Events.Event


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
                    , toasts = [ Toast Error "The mobber name cannot be empty" ]
                    }

        Add mobber ->
            { model = model
            , command =
                mobber
                    |> Peers.Events.AddedMobber
                    |> Peers.Events.MobEvent mob
                    |> Peers.Events.mobEventToJson
                    |> Peers.Events.sendEvent
            , toasts = []
            }

        Shuffle ->
            { model = model
            , command = Random.generate (ShareEvent << Peers.Events.ShuffledMobbers) <| Mobbers.shuffle mobbers
            , toasts = []
            }

        ShareEvent event ->
            -- TODO duplicated code
            { model = model
            , command =
                event
                    |> Peers.Events.MobEvent mob
                    |> Peers.Events.mobEventToJson
                    |> Peers.Events.sendEvent
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
                , onClick <| ShareEvent <| Peers.Events.RotatedMobbers
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
                            [ onClick <| ShareEvent <| Peers.Events.DeletedMobber mobber ]
                            [ Icons.delete ]
                        ]
                    ]
            )
