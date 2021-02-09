module Settings.Sound exposing (..)

import Html exposing (Html, button, div, i, input, label, p, text)
import Html.Attributes exposing (class, classList, for, id, step, type_, value)
import Html.Events exposing (onClick, onInput)
import Json.Encode
import Sounds


type alias Model =
    { profile : Sounds.Profile
    , volume : Int
    }

init : Model
init =
    { profile = Sounds.ClassicWeird
    , volume = 50
    }


type Msg
    = VolumeChanged String
    | SelectedSoundProfile Sounds.Profile


update : Msg -> Model -> (Json.Encode.Value -> Cmd Msg) -> ( Model, Cmd Msg )
update msg model soundCommandsPort =
    case msg of
        VolumeChanged volume ->
            ( { model | volume = String.toInt volume |> Maybe.withDefault model.volume }
            , soundCommandsPort <| changeVolume volume
            )

        SelectedSoundProfile profile ->
            ( { model | profile = profile }
            , Cmd.none
            )


changeVolume : String -> Json.Encode.Value
changeVolume volume =
    Json.Encode.object
        [ ( "name", Json.Encode.string "volume" )
        , ( "data"
          , Json.Encode.object
                [ ( "volume", Json.Encode.string volume ) ]
          )
        ]



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
                    [ classList [ ( "active", model.profile == Sounds.ClassicWeird ) ]
                    , onClick <| SelectedSoundProfile Sounds.ClassicWeird
                    ]
                    [ i [ class "fas fa-grin-stars" ] []
                    , p [] [ text "Classic Weird" ]
                    ]
                , button
                    [ classList [ ( "active", model.profile == Sounds.Riot ) ]
                    , onClick <| SelectedSoundProfile Sounds.Riot
                    ]
                    [ i [ class "fas fa-flag" ] []
                    , p [] [ text "Revolution" ]
                    ]
                ]
            ]
        ]
