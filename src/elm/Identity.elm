module Identity exposing (..)

import Html exposing (Html, div, input, text)
import Html.Attributes exposing (class, placeholder, required, type_, value)
import Html.Events exposing (onBlur, onInput)
import Json.Encode
import Mob exposing (MobberId)
import NEString exposing (NEString)
import Validation exposing (ValidationResult)

type alias Model =
    { nicknameField: (ValidationResult NEString)
    , id : Maybe MobberId
    , nickname: Maybe NEString
    }

empty : Model
empty =
    { nicknameField = Validation.initial
    , id = Nothing
    , nickname = Nothing
    }

type Msg
    = IdGenerated MobberId
    | NicknameChanged (ValidationResult NEString)
    | SaveIdentity (Model -> Cmd Msg)

update : Model -> Msg -> (Json.Encode.Value -> Cmd Msg) -> (Model, Cmd Msg)
update model msg save =
    case msg of
        IdGenerated id ->
            ({ model | id = Just id }, Cmd.none)
        NicknameChanged nickname ->
            ({ model | nicknameField = nickname }, Cmd.none)
        SaveIdentity extraCommand ->
            case (model.nicknameField, model.id) of
                (Validation.Valid nickname, Just id) ->
                    ( { model | nickname = Just nickname }
                    , Cmd.batch
                        [ save <| Mob.mobberEncoder (Mob.Mobber nickname id)
                        , extraCommand model
                        ]
                    )
                (_, _) -> (model, Cmd.none )


view : Model -> (Msg -> a) -> Html a
view model toMain =
    div [ class "text-field" ]
        [ div
            [ class "form-error" ]
            [ Validation.message model.nicknameField |> Maybe.withDefault "" |> text ]
        , input
            [ type_ "text"
            , required True
            , onInput (Validation.validate mobberNameRules >> NicknameChanged >> toMain)
            , placeholder "How should we call you ?"
            , value <| Validation.toString NEString.toString model.nicknameField
            ]
            []
        ]

mobberNameRules : String -> Result String NEString
mobberNameRules raw =
    NEString.from raw
    |> Result.fromMaybe "Your nickname cannot be empty"