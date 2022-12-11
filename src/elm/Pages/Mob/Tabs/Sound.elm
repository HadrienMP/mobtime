module Pages.Mob.Tabs.Sound exposing (..)

import Effect exposing (Effect)
import Html.Styled exposing (Html, button, div, img, p, text)
import Html.Styled.Attributes as Attr exposing (class, classList, id, src)
import Html.Styled.Events exposing (onClick)
import Json.Encode
import Model.Events
import Model.MobName exposing (MobName)
import Shared exposing (Shared)
import Sounds as SoundLibrary


type alias CommandPort =
    Json.Encode.Value -> Cmd Msg


type alias StorePort =
    Json.Encode.Value -> Cmd Msg


type Msg
    = ShareEvent Model.Events.MobEvent


update : Msg -> Effect Shared.Msg Msg
update msg =
    case msg of
        ShareEvent event ->
            Effect.share event


view : Shared -> MobName -> SoundLibrary.Profile -> Html Msg
view _ mob activeProfile =
    div [ id "sound", class "tab" ]
        [ div
            [ id "sounds-field", class "form-field" ]
            [ div
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
