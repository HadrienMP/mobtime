module Pages.Mob.Sound.Settings exposing (..)

import Html exposing (Html, button, div, img, input, label, p, text)
import Html.Attributes exposing (alt, class, classList, for, id, src, type_, value)
import Html.Events exposing (onClick, onInput)
import Js.Commands
import Json.Encode
import Lib.Icons.Ion exposing (musicNote)
import Model.MobName exposing (MobName)
import Sounds as SoundLibrary
import Peers.Events


type alias CommandPort =
    Json.Encode.Value -> Cmd Msg


type alias StorePort =
    Json.Encode.Value -> Cmd Msg


type alias Model =
    { volume : Int }


init : Int -> Model
init volume =
    { volume = volume }


type Msg
    = VolumeChanged String
    | ShareEvent Peers.Events.MobEvent
    | TestTheSound


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        VolumeChanged rawVolume ->
            let
                volume =
                    String.toInt rawVolume |> Maybe.withDefault model.volume
            in
            ( { model | volume = volume }
            , Js.Commands.send <| Js.Commands.ChangeVolume volume
            )

        ShareEvent event ->
            ( model
            , event
                |> Peers.Events.mobEventToJson
                |> Peers.Events.sendEvent
            )

        TestTheSound ->
            ( model
            , Js.Commands.send <| Js.Commands.TestTheSound
            )


view : Model -> MobName -> SoundLibrary.Profile -> Html Msg
view model mob profile =
    div [ id "sound", class "tab" ]
        [ div
            [ id "volume-field", class "form-field" ]
            [ label [ for "volume" ] [ text "Volume" ]
            , Lib.Icons.Ion.volumeLow
            , input
                [ id "volume"
                , type_ "range"
                , onInput VolumeChanged
                , Html.Attributes.max "50"
                , value <| String.fromInt model.volume
                ]
                []
            , Lib.Icons.Ion.volumeHigh
            ]
        , button
            [ id "test-audio"
            , class "labelled-icon-button"
            , onClick TestTheSound
            ]
            [ musicNote, text "Test the audio !" ]
        , div
            [ id "sounds-field", class "form-field" ]
            [ label [] [ text "Playlist" ]
            , div
                [ id "sound-cards" ]
                [ button
                    [ classList [ ( "active", profile == SoundLibrary.ClassicWeird ) ]
                    , onClick
                        (SoundLibrary.ClassicWeird
                            |> Peers.Events.SelectedMusicProfile
                            |> Peers.Events.MobEvent mob
                            |> ShareEvent
                        )
                    ]
                    [ img [ src "/images/weird.jpeg", alt "Man wearing a watermelon as a hat" ] []
                    , p [] [ text "Classic Weird" ]
                    ]
                , button
                    [ classList [ ( "active", profile == SoundLibrary.Riot ) ]
                    , onClick
                        (SoundLibrary.Riot
                            |> Peers.Events.SelectedMusicProfile
                            |> Peers.Events.MobEvent mob
                            |> ShareEvent
                        )
                    ]
                    [ img [ src "/images/commune.jpg", alt "Comic book drawing of the paris commune revolution" ] []
                    , p [] [ text "Revolution" ]
                    ]
                ]
            ]
        ]
