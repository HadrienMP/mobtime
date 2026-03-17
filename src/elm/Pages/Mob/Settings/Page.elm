module Pages.Mob.Settings.Page exposing (Model, Msg(..), init, subscriptions, update, view)

import Components.Form.Volume.Field as VolumeField
import Effect exposing (Effect)
import Lib.Duration exposing (Duration)
import Lib.NonEmptyList as NonEmptyList
import Model.Events
import Model.Mob exposing (Mob)
import Model.Roles as Roles
import Pages.Mob.Routing
import Pages.Mob.Settings.PageView
import Playlist.Types exposing (Playlist)
import Routing
import Shared exposing (Shared)
import UserPreferences
import View exposing (View)



-- Model


type alias Model =
    { rawRoles : Maybe String }


init : Model
init =
    { rawRoles = Nothing }



-- Update


type Msg
    = Back
    | TurnChange Duration
    | PomodoroChange Duration
    | PlaylistToggled Playlist
    | VolumeMsg VolumeField.Msg
    | ExtremeModeToggle
    | ToggleStopAutomatically
    | RolesChange String


update : Shared -> Mob -> Msg -> Model -> ( Model, Effect Shared.Msg Msg )
update shared mob msg model =
    case msg of
        Back ->
            ( model
            , Shared.pushUrl shared <|
                Routing.Mob <|
                    { subRoute = Pages.Mob.Routing.Home, mob = mob.name }
            )

        TurnChange turn ->
            ( model
            , turn
                |> Model.Events.TurnLengthChanged
                |> Model.Events.MobEvent mob.name
                |> Effect.share
            )

        PomodoroChange pomodoro ->
            ( model
            , pomodoro
                |> Model.Events.PomodoroLengthChanged
                |> Model.Events.MobEvent mob.name
                |> Effect.share
            )

        PlaylistToggled playlist ->
            ( model
            , mob.playlists
                |> NonEmptyList.toggle playlist
                |> Model.Events.SelectedPlaylists
                |> Model.Events.MobEvent mob.name
                |> Effect.share
            )

        VolumeMsg volumeMsg ->
            ( model
            , UserPreferences.VolumeMsg volumeMsg
                |> Shared.PreferencesMsg
                |> Effect.fromShared
            )

        ExtremeModeToggle ->
            ( model
            , not mob.extremeMode
                |> Model.Events.ExtremeModeChanged
                |> Model.Events.MobEvent mob.name
                |> Effect.share
            )

        RolesChange roles ->
            ( { model | rawRoles = Just roles }
            , Roles.parse roles
                |> Model.Events.ChangedRoles
                |> Model.Events.MobEvent mob.name
                |> Effect.share
            )

        ToggleStopAutomatically ->
            ( model
            , not mob.stopAutomatically
                |> Model.Events.StopAutomatically
                |> Model.Events.MobEvent mob.name
                |> Effect.share
            )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


view : Shared -> Mob -> Model -> View Msg
view shared mob model =
    { title = "Settings"
    , modal = Nothing
    , body =
        Pages.Mob.Settings.PageView.view
            { active = mob.playlists
            , devMode = shared.devMode
            , mob = mob.name
            , onBack = Back
            , onPlaylistChange = PlaylistToggled
            , onPomodoroChange = PomodoroChange
            , onTurnLengthChange = TurnChange
            , onExtremeModeChange = ExtremeModeToggle
            , extremeMode = mob.extremeMode
            , rawRoles = model.rawRoles |> Maybe.withDefault (Roles.toString mob.roles)
            , onRoleChange = RolesChange
            , stopAutomatically = mob.stopAutomatically
            , onStopAutomatically = ToggleStopAutomatically
            , pomodoro = mob.pomodoroLength
            , turnLength = mob.turnLength
            , volume =
                { onChange = VolumeMsg << VolumeField.Change
                , onTest = VolumeMsg VolumeField.Test
                , volume = shared.preferences.volume
                }
            }
    }
