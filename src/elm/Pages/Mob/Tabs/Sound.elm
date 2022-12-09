module Pages.Mob.Tabs.Sound exposing (..)

import Css
import Effect exposing (Effect)
import Html.Styled as Html exposing (Html, button, div, img, label, p, text)
import Html.Styled.Attributes as Attr exposing (class, classList, id, src)
import Html.Styled.Events exposing (onClick)
import Json.Encode
import Model.Events
import Model.MobName exposing (MobName)
import Shared exposing (Shared)
import Sounds as SoundLibrary
import Volume


type alias CommandPort =
    Json.Encode.Value -> Cmd Msg


type alias StorePort =
    Json.Encode.Value -> Cmd Msg


type Msg
    = ShareEvent Model.Events.MobEvent
    | VolumeMsg Volume.Msg


update : Msg -> Effect Shared.Msg Msg
update msg =
    case msg of
        VolumeMsg subMsg ->
            Effect.fromShared <| Shared.VolumeMsg subMsg

        ShareEvent event ->
            Effect.share event


view : Shared -> MobName -> SoundLibrary.Profile -> Html Msg
view shared mob activeProfile =
    div [ id "sound", class "tab" ]
        [ Volume.view
            shared.preferences.volume
            { labelWidth = Css.width <| Css.pct 30 }
            |> Html.map VolumeMsg
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
