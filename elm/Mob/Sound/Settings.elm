module Mob.Sound.Settings exposing (..)

import Html exposing (Html, button, div, i, input, label, p, text)
import Html.Attributes exposing (class, classList, for, id, step, type_, value)
import Html.Events exposing (onClick, onInput)
import Interface.Commands
import Json.Encode
import Mob.Sound.Library as SoundLibrary
import UserPreferences

type alias CommandPort = (Json.Encode.Value -> Cmd Msg)
type alias StorePort = (Json.Encode.Value -> Cmd Msg)

type alias Model =
    { profile : SoundLibrary.Profile
    , volume : Int
    }


init : Int -> Model
init volume =
    { profile = SoundLibrary.ClassicWeird
    , volume = volume
    }


type Msg
    = VolumeChanged String
    | SelectedSoundProfile SoundLibrary.Profile


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        VolumeChanged rawVolume ->
            let
                volume = String.toInt rawVolume|> Maybe.withDefault model.volume
            in
            ( { model | volume = volume }
            , Cmd.batch
                [ Interface.Commands.send <| Interface.Commands.ChangeVolume volume
                , Interface.Commands.send <| Interface.Commands.StoreVolume volume
                ]
            )

        SelectedSoundProfile profile ->
            ( { model | profile = profile }
            , Cmd.none
            )


changeVolume : Int -> Json.Encode.Value
changeVolume volume =
    Json.Encode.object
        [ ( "name", Json.Encode.string "volume" )
        , ( "data"
          , Json.Encode.object
                [ ( "volume", Json.Encode.int volume ) ]
          )
        ]

store : Int -> Json.Encode.Value
store volume =
    UserPreferences.encode <| UserPreferences.Model volume


view : Model -> Html Msg
view model =
    div [ id "sound", class "tab" ]
        [ div
            [ id "volume-field", class "form-field" ]
            [ label [ for "volume" ] [ text "Volume" ]
            , i [ class "fas fa-volume-down" ] []
            , input
                [ id "volume"
                , type_ "range"
                , onInput VolumeChanged
                , step "10"
                , value <| String.fromInt model.volume
                ]
                []
            , i [ class "fas fa-volume-up" ] []
            ]
        , div
            [ id "sounds-field", class "form-field" ]
            [ label [] [ text "Profiles" ]
            , div
                [ id "sound-cards" ]
                [ button
                    [ classList [ ( "active", model.profile == SoundLibrary.ClassicWeird ) ]
                    , onClick <| SelectedSoundProfile SoundLibrary.ClassicWeird
                    ]
                    [ i [ class "fas fa-grin-stars" ] []
                    , p [] [ text "Classic Weird" ]
                    ]
                , button
                    [ classList [ ( "active", model.profile == SoundLibrary.Riot ) ]
                    , onClick <| SelectedSoundProfile SoundLibrary.Riot
                    ]
                    [ i [ class "fas fa-flag" ] []
                    , p [] [ text "Revolution" ]
                    ]
                ]
            ]
        ]
