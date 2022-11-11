module Model.State exposing (..)

import Js.Commands
import Lib.Duration as Duration exposing (Duration)
import Lib.ListExtras exposing (uncons)
import Model.Clock exposing (ClockState(..))
import Model.Events as Events
import Model.Mobber exposing (Mobber)
import Model.Mobbers as Mobbers exposing (Mobbers)
import Model.Role exposing (Role)
import Model.Roles
import Sounds
import Time


type alias State =
    { clock : ClockState
    , turnLength : Duration
    , pomodoro : ClockState
    , pomodoroLength : Duration
    , mobbers : Mobbers
    , roles : Model.Roles.Roles
    , soundProfile : Sounds.Profile
    }


init : State
init =
    { clock = Off
    , turnLength = defaultTurnLength
    , pomodoro = Off
    , pomodoroLength = defaultPomodoroLength
    , mobbers = Mobbers.empty
    , roles = Model.Roles.default
    , soundProfile = Sounds.ClassicWeird
    }


defaultTurnLength : Duration
defaultTurnLength =
    Duration.ofMinutes 8


defaultPomodoroLength : Duration
defaultPomodoroLength =
    Duration.ofMinutes 25


type alias TimePassedResult =
    { updated : State
    , turnEvent : Model.Clock.Event
    }


timePassed : Time.Posix -> State -> TimePassedResult
timePassed now state =
    let
        ( clock, event ) =
            Model.Clock.timePassed now state.clock
    in
    { updated = { state | clock = clock }
    , turnEvent = event
    }


evolve : Events.Event -> State -> ( State, Cmd msg )
evolve event state =
    evolve_ event ( state, Cmd.none )


evolve_ : Events.Event -> ( State, Cmd msg ) -> ( State, Cmd msg )
evolve_ event ( state, previousCommand ) =
    case event of
        Events.Clock clockEvent ->
            evolveClock clockEvent state

        Events.ChangedRoles roles ->
            ( { state | roles = roles }
            , previousCommand
            )

        Events.AddedMobber mobber ->
            ( { state | mobbers = Mobbers.add mobber state.mobbers }
            , previousCommand
            )

        Events.DeletedMobber mobber ->
            ( { state | mobbers = Mobbers.delete mobber state.mobbers }
            , previousCommand
            )

        Events.RotatedMobbers ->
            ( { state | mobbers = Mobbers.rotate state.mobbers }
            , previousCommand
            )

        Events.ShuffledMobbers mobbers ->
            ( { state | mobbers = Mobbers.merge mobbers state.mobbers }
            , previousCommand
            )

        Events.TurnLengthChanged turnLength ->
            ( { state | turnLength = turnLength }
            , previousCommand
            )

        Events.SelectedMusicProfile profile ->
            ( { state | soundProfile = profile }
            , previousCommand
            )

        Events.Unknown _ ->
            ( state
            , previousCommand
            )

        Events.PomodoroStopped ->
            ( { state | pomodoro = Off }
            , previousCommand
            )

        Events.PomodoroLengthChanged duration ->
            ( { state | pomodoroLength = duration }
            , previousCommand
            )


evolveMany : List Events.Event -> State -> ( State, Cmd msg )
evolveMany events model =
    evolveMany_ events ( model, Cmd.none )


evolveMany_ : List Events.Event -> ( State, Cmd msg ) -> ( State, Cmd msg )
evolveMany_ events previous =
    case uncons events of
        ( Nothing, _ ) ->
            previous

        ( Just first, others ) ->
            evolveMany_ others (evolve_ first previous)


evolveClock : Events.ClockEvent -> State -> ( State, Cmd msg )
evolveClock event state =
    case ( event, state.clock ) of
        ( Events.Started started, Off ) ->
            ( { state
                | clock =
                    On
                        { end = Duration.addToTime started.length started.time
                        , length = started.length
                        , ended = False
                        }
                , pomodoro =
                    case state.pomodoro of
                        On _ ->
                            state.pomodoro

                        Off ->
                            On
                                { end = Duration.addToTime state.pomodoroLength started.time
                                , length = state.pomodoroLength
                                , ended = False
                                }
              }
            , Js.Commands.send <| Js.Commands.SetAlarm started.alarm
            )

        ( Events.Stopped, On _ ) ->
            ( { state
                | clock = Off
                , mobbers = Mobbers.rotate state.mobbers
              }
            , Cmd.none
            )

        _ ->
            ( state, Cmd.none )


assignRoles : State -> List ( Role, Mobber )
assignRoles state =
    Mobbers.assignRoles state.roles state.mobbers


assignSpecialRoles : State -> List ( Role, Mobber )
assignSpecialRoles state =
    Mobbers.assignSpecialRoles state.roles state.mobbers
