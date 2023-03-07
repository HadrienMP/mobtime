module Pages.Mob.Settings.Page exposing (Msg(..), subscriptions, update, view)

import Effect exposing (Effect)
import Lib.Duration exposing (Duration)
import Model.Events
import Model.Mob
import Pages.Mob.Routing
import Pages.Mob.Settings.PageView
import Routing
import Shared exposing (Shared)
import Sounds
import View exposing (View)


type Msg
    = Back
    | TurnChange Duration
    | PomodoroChange Duration
    | PlaylistChange Sounds.Profile


update : Shared -> Msg -> Model.Mob.Mob -> ( Model.Mob.Mob, Effect Shared.Msg Msg )
update shared msg model =
    case msg of
        Back ->
            ( model
            , Shared.pushUrl shared <|
                Routing.Mob <|
                    { subRoute = Pages.Mob.Routing.Home, name = model.name }
            )

        TurnChange turn ->
            ( model
            , turn
                |> Model.Events.TurnLengthChanged
                |> Model.Events.MobEvent model.name
                |> Effect.share
            )

        PomodoroChange pomodoro ->
            ( model
            , pomodoro
                |> Model.Events.PomodoroLengthChanged
                |> Model.Events.MobEvent model.name
                |> Effect.share
            )

        PlaylistChange playlist ->
            ( model
            , playlist
                |> Model.Events.SelectedMusicProfile
                |> Model.Events.MobEvent model.name
                |> Effect.share
            )


subscriptions : Model.Mob.Mob -> Sub Msg
subscriptions _ =
    Sub.none


view : Model.Mob.Mob -> View Msg
view model =
    { title = "Settings"
    , modal = Nothing
    , body =
        Pages.Mob.Settings.PageView.view
            { mob = model.name
            , turnLength = model.turnLength
            , pomodoro = model.pomodoroLength
            , currentPlaylist = model.soundProfile
            , onBack = Back
            , onTurnLengthChange = TurnChange
            , onPomodoroChange = PomodoroChange
            , onPlaylistChange = PlaylistChange
            }
    }
