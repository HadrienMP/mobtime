module Pages.Mob.Tabs.Sound exposing (..)

import Html.Styled exposing (Html, button, div, img, input, label, p, text)
import Html.Styled.Attributes as Attr exposing (class, classList, for, id, src, type_, value)
import Html.Styled.Events exposing (onClick, onInput)
import Js.Commands
import Json.Encode
import UI.Icons.Ion exposing (musicNote)
import Model.Events
import Model.MobName exposing (MobName)
import Sounds as SoundLibrary


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
    | ShareEvent Model.Events.MobEvent
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
                |> Model.Events.mobEventToJson
                |> Model.Events.sendEvent
            )

        TestTheSound ->
            ( model
            , Js.Commands.send <| Js.Commands.TestTheSound
            )


view : Model -> MobName -> SoundLibrary.Profile -> Html Msg
view model mob activeProfile =
    div [ id "sound", class "tab" ]
        [ div
            [ id "volume-field", class "form-field" ]
            [ label [ for "volume" ] [ text "Volume" ]
            , UI.Icons.Ion.volumeLow
            , input
                [ id "volume"
                , type_ "range"
                , onInput VolumeChanged
                , Attr.max "50"
                , value <| String.fromInt model.volume
                ]
                []
            , UI.Icons.Ion.volumeHigh
            ]
        , button
            [ id "test-audio"
            , class "labelled-icon-button"
            , onClick TestTheSound
            ]
            [ musicNote
            , text "Test the audio !"
            ]
        , div
            [ id "sounds-field", class "form-field" ]
            [ label [] [ text "Playlist" ]
            , div
                [ id "sound-cards" ]
                (SoundLibrary.allProfiles
                    |> List.map (\profile -> viewProfile { active = activeProfile, current = profile } mob)
                )
            ]
        ]


viewProfile : { active : SoundLibrary.Profile, current : SoundLibrary.Profile } -> MobName -> Html Msg
viewProfile { active, current } mob =
    button
        [ classList [ ( "active", active == current ) ]
        , onClick
            (current
                |> Model.Events.SelectedMusicProfile
                |> Model.Events.MobEvent mob
                |> ShareEvent
            )
        ]
        [ SoundLibrary.poster current |> viewPoster
        , p [] [ text <| SoundLibrary.title current ]
        ]


viewPoster : SoundLibrary.Image -> Html Msg
viewPoster { url, alt } =
    img [ src url, Attr.alt alt ] []
