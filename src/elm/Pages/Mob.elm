module Pages.Mob exposing (ActionDescription, AlarmState(..), Model, Msg(..), Tab(..), init, jsEventMapping, subscriptions, update, view)

import Components.Socket.Socket
import Css
import Effect exposing (Effect)
import Html.Styled as Html exposing (..)
import Html.Styled.Attributes as Attr exposing (class, classList, css, id, title)
import Html.Styled.Events exposing (onClick)
import Js.Commands
import Js.Events
import Js.EventsMapping as EventsMapping exposing (EventsMapping)
import Lib.Duration as Duration exposing (DurationStringParts)
import Model.Clock as Clock exposing (ClockState(..))
import Model.Events
import Model.MobName exposing (MobName)
import Model.State
import Pages.Mob.Share.Button
import Pages.Mob.Tabs.Clocks
import Pages.Mob.Tabs.Dev
import Pages.Mob.Tabs.Home
import Pages.Mob.Tabs.Mobbers
import Pages.Mob.Tabs.Sound
import Random
import Routing
import Shared exposing (Shared)
import Sounds
import Svg.Styled exposing (Svg)
import Task
import Time
import UI.Button.View as Button
import UI.CircularProgressBar
import UI.Color as Color
import UI.Column as Column
import UI.Css
import UI.Icons
import UI.Icons.Ion
import UI.Icons.Tape
import UI.Icons.Tea
import UI.Modal.View
import UI.Palettes as Palettes
import UI.Rem as Rem
import UI.Text as Text
import View exposing (View)



-- MODEL


type AlarmState
    = Playing
    | Stopped
    | Standby


type Tab
    = Main
    | Mobbers
    | Clock
    | Sound
    | Dev


type alias Model =
    { name : MobName
    , state : Model.State.State
    , mobbersSettings : Pages.Mob.Tabs.Mobbers.Model
    , alarm : AlarmState
    , now : Time.Posix
    , tab : Tab
    }


init : Shared -> MobName -> ( Model, Effect Shared.Msg Msg )
init shared name =
    let
        redirection =
            if shared.soundOn then
                Effect.none

            else
                Shared.pushUrl shared <| Routing.Profile name
    in
    ( { name = name
      , state = Model.State.init
      , mobbersSettings = Pages.Mob.Tabs.Mobbers.init
      , alarm = Standby
      , now = Time.millisToPosix 0
      , tab = Main
      }
    , Effect.batch
        [ Effect.fromCmd <| Components.Socket.Socket.joinRoom <| Model.MobName.print name
        , Time.now |> Task.perform TimePassed |> Effect.fromCmd
        , redirection
        ]
    )



-- UPDATE


type Msg
    = ShareEvent Model.Events.MobEvent
    | ReceivedEvent Model.Events.Event
    | ReceivedHistory (List Model.Events.Event)
    | StartClicked
    | StartWith ( Time.Posix, Sounds.Sound )
    | StopSound
    | AlarmEnded
    | TimePassed Time.Posix
    | GotMainTabMsg Pages.Mob.Tabs.Home.Msg
    | GotClockSettingsMsg Pages.Mob.Tabs.Clocks.Msg
    | GotMobbersSettingsMsg Pages.Mob.Tabs.Mobbers.Msg
    | GotSoundSettingsMsg Pages.Mob.Tabs.Sound.Msg
    | SwitchTab Tab


timePassed : Time.Posix -> Shared -> Model -> ( Model, Cmd Msg )
timePassed now shared model =
    let
        timePassedResult =
            Model.State.timePassed now model.state

        alarmCommand =
            case timePassedResult.turnEvent of
                Clock.Ended ->
                    Js.Commands.send Js.Commands.SoundAlarm

                Clock.Continued ->
                    Cmd.none
    in
    ( { model
        | alarm =
            case timePassedResult.turnEvent of
                Clock.Ended ->
                    Playing

                Clock.Continued ->
                    model.alarm
        , now = now
        , state = timePassedResult.updated
      }
    , Cmd.batch
        [ alarmCommand
        , Js.Commands.send <|
            Js.Commands.ChangeTitle <|
                timeLeftTitle model.name <|
                    timeLeftString shared model
        ]
    )


update : Shared -> Msg -> Model -> ( Model, Effect Shared.Msg Msg )
update shared msg model =
    case msg of
        ShareEvent event ->
            ( model
            , Effect.share event
            )

        ReceivedEvent event ->
            let
                ( updated, command ) =
                    Model.State.evolve event model.state
            in
            ( { model
                | state = updated
                , alarm =
                    -- Handle alarm (command) as separate from the evolve method ?
                    case event of
                        Model.Events.Clock (Model.Events.Started _) ->
                            Stopped

                        _ ->
                            model.alarm
              }
            , Effect.fromCmd command
            )

        ReceivedHistory eventsResults ->
            let
                ( updated, command ) =
                    Model.State.evolveMany eventsResults model.state
            in
            ( { model | state = updated }
            , Effect.fromCmd command
            )

        StartClicked ->
            ( model
            , Time.now
                |> Task.map
                    (\now -> ( now, selectSound now model.state.soundProfile ))
                |> Task.perform StartWith
                |> Effect.fromCmd
            )

        StartWith ( now, sound ) ->
            ( { model | now = now }
            , Model.Events.Started
                { time = now
                , alarm = sound
                , length = model.state.turnLength
                }
                |> Model.Events.Clock
                |> Model.Events.MobEvent model.name
                |> Effect.share
            )

        StopSound ->
            ( { model | alarm = Stopped }
            , Effect.js Js.Commands.StopAlarm
            )

        AlarmEnded ->
            ( { model | alarm = Stopped }
            , Effect.fromCmd <| Cmd.none
            )

        GotMainTabMsg subMsg ->
            ( model
            , Pages.Mob.Tabs.Home.update subMsg
                |> Cmd.map GotMainTabMsg
                |> Effect.fromCmd
            )

        GotMobbersSettingsMsg subMsg ->
            let
                ( updated, command ) =
                    Pages.Mob.Tabs.Mobbers.update subMsg model.state.mobbers model.name model.mobbersSettings
            in
            ( { model | mobbersSettings = updated }
            , Effect.map GotMobbersSettingsMsg command
            )

        SwitchTab tab ->
            ( { model | tab = tab }
            , Effect.none
            )

        GotClockSettingsMsg subMsg ->
            ( model
            , Pages.Mob.Tabs.Clocks.update subMsg model.name
                |> Effect.map GotClockSettingsMsg
            )

        GotSoundSettingsMsg subMsg ->
            ( model
            , Effect.map GotSoundSettingsMsg <| Pages.Mob.Tabs.Sound.update subMsg
            )

        TimePassed now ->
            let
                ( updated, command ) =
                    timePassed now shared model
            in
            ( updated
            , Effect.fromCmd command
            )


selectSound : Time.Posix -> Sounds.Profile -> Sounds.Sound
selectSound now profile =
    Random.step (Sounds.pick profile)
        (now
            |> Time.posixToMillis
            |> Random.initialSeed
        )
        |> Tuple.first



-- SUBSCRIPTIONS


turnRefreshRate : Duration.Duration
turnRefreshRate =
    Duration.ofMillis 500


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Model.Events.receiveOne <| Model.Events.fromJson >> ReceivedEvent
        , Model.Events.receiveHistory <| List.map Model.Events.fromJson >> ReceivedHistory
        , case ( Clock.isOn model.state.clock, Clock.isOn model.state.pomodoro ) of
            ( True, _ ) ->
                Time.every (Duration.toMillis turnRefreshRate |> toFloat) TimePassed

            ( False, True ) ->
                Time.every 2000 TimePassed

            _ ->
                Sub.none
        ]


jsEventMapping : EventsMapping Msg
jsEventMapping =
    EventsMapping.batch
        [ EventsMapping.create <|
            [ Js.Events.EventMessage "AlarmEnded" (always AlarmEnded)
            ]
        ]



-- VIEW


view : Shared -> Model -> View Msg
view shared model =
    let
        action =
            detectAction shared model
    in
    { title = timeLeftTitle model.name action.timeLeft
    , modal =
        case ( model.alarm, model.state.clock, model.state.pomodoro ) of
            ( Playing, _, _ ) ->
                Just musicModal

            ( _, Clock.Off, Clock.On pomodoro ) ->
                if Duration.secondsBetween model.now pomodoro.end <= 0 then
                    Just <| breakModal model.name

                else
                    Nothing

            _ ->
                Nothing
    , body = body shared model action
    }


body : Shared -> Model -> ActionDescription -> Html Msg
body shared model action =
    div
        [ class "container"
        , Attr.css
            [ Css.position Css.relative
            ]
        ]
        [ clockArea model action
        , Pages.Mob.Share.Button.view
            [ Attr.css
                [ Css.position Css.absolute
                , Css.top <| Css.rem 10
                , Css.left <| Css.calc (Css.pct 50) Css.minus (Css.rem 5)
                ]
            ]
            { sharePage = Routing.toUrl <| Routing.Share model.name
            , color = Palettes.monochrome.on.background
            }
        , nav []
            ([ button
                [ onClick <| SwitchTab Main
                , classList [ ( "active", model.tab == Main ) ]
                , title "Home"
                ]
                [ UI.Icons.Ion.home
                    { size = Rem.Rem 3
                    , color = Palettes.monochrome.on.surface
                    }
                ]
             , button
                [ onClick <| SwitchTab Clock
                , classList [ ( "active", model.tab == Clock ) ]
                , title "Clock Settings"
                ]
                [ UI.Icons.Ion.clock
                    { size = Rem.Rem 3
                    , color = Palettes.monochrome.on.surface
                    }
                ]
             , button
                [ onClick <| SwitchTab Mobbers
                , classList [ ( "active", model.tab == Mobbers ) ]
                , title "Mobbers"
                ]
                [ UI.Icons.Ion.people
                    { size = Rem.Rem 3
                    , color = Palettes.monochrome.on.surface
                    }
                ]
             , button
                [ onClick <| SwitchTab Sound
                , classList [ ( "active", model.tab == Sound ) ]
                , title "Sound Settings"
                ]
                [ UI.Icons.Ion.sound
                    { size = Rem.Rem 3
                    , color = Palettes.monochrome.on.surface
                    }
                ]
             ]
                ++ (if shared.devMode then
                        [ button
                            [ onClick <| SwitchTab Dev
                            , classList [ ( "active", model.tab == Dev ) ]
                            , title "Dev"
                            ]
                            [ UI.Icons.Ion.code
                                { size = Rem.Rem 1
                                , color = Palettes.monochrome.on.background
                                }
                            ]
                        ]

                    else
                        []
                   )
            )
        , case model.tab of
            Main ->
                Pages.Mob.Tabs.Home.view shared model.name model.state
                    |> Html.map GotMainTabMsg

            Clock ->
                Pages.Mob.Tabs.Clocks.view shared model.now model.state
                    |> Html.map GotClockSettingsMsg

            Mobbers ->
                Pages.Mob.Tabs.Mobbers.view model.state model.mobbersSettings
                    |> Html.map GotMobbersSettingsMsg

            Sound ->
                Pages.Mob.Tabs.Sound.view shared model.name model.state.soundProfile
                    |> Html.map GotSoundSettingsMsg

            Dev ->
                Pages.Mob.Tabs.Dev.view
        ]


musicModal : UI.Modal.View.Modal Msg
musicModal =
    { onClose = StopSound
    , content =
        Column.column
            [ css UI.Css.center ]
            [ Column.Gap <| Rem.Rem 2 ]
            [ UI.Icons.Tape.display
                { size = Rem.Rem 10
                , color = Palettes.monochrome.on.background
                }
            , Text.h2 [] "Turn ended !"
            , Button.button [ css [ Css.width <| Css.pct 100 ] ]
                { content = Button.Both { icon = UI.Icons.Ion.mute, text = "Stop music" }
                , variant = Button.Primary
                , size = Button.L
                , action = Button.OnPress <| Just StopSound
                }
            ]
    }


breakModal : MobName -> UI.Modal.View.Modal Msg
breakModal mobName =
    let
        action =
            Model.Events.PomodoroStopped
                |> Model.Events.MobEvent mobName
                |> ShareEvent
    in
    { onClose = action
    , content =
        Column.column
            [ css UI.Css.center ]
            [ Column.Gap <| Rem.Rem 2 ]
            [ Text.h2 [] "It's time for a break!"
            , UI.Icons.Tea.display
                { height = Rem.Rem 10
                , color = Palettes.monochrome.on.background
                }
            , Html.p
                [ css [ Css.textAlign Css.justify ] ]
                [ Html.text "Boost your productivity by taking a good break." ]
            , Button.button [ css [ Css.width <| Css.pct 100 ] ]
                { content = Button.Both { icon = UI.Icons.Ion.check, text = "Break over" }
                , variant = Button.Primary
                , size = Button.L
                , action = Button.OnPress <| Just action
                }
            ]
    }


clockArea : Model -> ActionDescription -> Html Msg
clockArea model action =
    header []
        [ section []
            [ Html.div
                [ css
                    [ Css.position Css.relative
                    , Css.margin Css.auto
                    , Css.maxWidth Css.fitContent
                    ]
                ]
                [ UI.CircularProgressBar.draw
                    { colors =
                        { main = Palettes.monochrome.surface |> Color.lighten 0.5
                        , background = Palettes.monochrome.surface |> Color.lighten 0.9
                        , border = Palettes.monochrome.surface |> Color.lighten 0.7
                        }
                    , strokeWidth = Rem.Rem 0.3
                    , diameter = Rem.Rem 8.7
                    , progress = Clock.ratio model.now model.state.pomodoro
                    , refreshRate = turnRefreshRate |> Duration.multiply 2
                    }
                , Html.div
                    [ css
                        [ Css.position Css.absolute
                        , Css.top <| Css.rem 0.4
                        , Css.left <| Css.rem 0.4
                        ]
                    ]
                    [ UI.CircularProgressBar.draw
                        { colors =
                            { main = Palettes.monochrome.surface
                            , background = Palettes.monochrome.surface |> Color.lighten 0.9
                            , border = Palettes.monochrome.surface |> Color.lighten 0.7
                            }
                        , strokeWidth = Rem.Rem 0.5
                        , diameter = Rem.Rem 7.8
                        , progress = Clock.ratio model.now model.state.clock
                        , refreshRate = turnRefreshRate |> Duration.multiply 2
                        }
                    ]
                , UI.Icons.style
                    { class = "action"
                    , size = Rem.Rem 3
                    , colors =
                        { normal = Palettes.monochrome.surface
                        , hover = Palettes.monochrome.surface
                        }
                    }
                  <|
                    actionButton action
                ]
            ]
        ]


actionButton : ActionDescription -> Html Msg
actionButton action =
    button
        [ onClick action.message
        , id "action"
        , class action.class
        , css
            [ Css.width <| Css.rem 6.6
            , Css.height <| Css.rem 6.6
            , Css.borderRadius <| Css.pct 100
            , Css.position Css.absolute
            , Css.top <| Css.rem 1.1
            , Css.left <| Css.rem 1.1
            , Css.flexDirection Css.column
            , Css.backgroundColor <|
                Color.toElmCss <|
                    Color.opactity 0.5 <|
                        Palettes.monochrome.background
            , Css.color <| Color.toElmCss <| Palettes.monochrome.surface
            , Css.hover
                [ Css.backgroundColor <|
                    Color.toElmCss <|
                        Color.opactity 0.8 <|
                            Palettes.monochrome.background
                ]
            ]
        ]
        [ div [] [ action.icon ]
        , div
            [ id "time-left"
            , css
                [ Css.fontWeight Css.bold
                , Css.fontSize <| Css.rem 1.6
                ]
            ]
            (action.timeLeft
                |> List.map
                    (\a ->
                        span
                            [ css [ Css.display Css.block ] ]
                            [ text a ]
                    )
            )
        ]


type alias ActionDescription =
    { icon : Svg Msg
    , message : Msg
    , timeLeft : DurationStringParts
    , class : String
    }


detectAction : Shared -> Model -> ActionDescription
detectAction shared model =
    let
        timeLeft =
            timeLeftString shared model
    in
    case model.state.clock of
        On _ ->
            { icon =
                UI.Icons.Ion.stop
                    { size = Rem.Rem 1
                    , color = Palettes.monochrome.on.background
                    }
            , message =
                Model.Events.Clock Model.Events.Stopped
                    |> Model.Events.MobEvent model.name
                    |> ShareEvent
            , class = "on"
            , timeLeft = timeLeft
            }

        Off ->
            { icon =
                UI.Icons.Ion.play
                    { size = Rem.Rem 1
                    , color = Palettes.monochrome.on.background
                    }
            , message = StartClicked
            , class = ""
            , timeLeft = timeLeft
            }


timeLeftString : Shared -> Model -> DurationStringParts
timeLeftString shared model =
    case model.state.clock of
        On on ->
            Duration.between model.now on.end
                |> (if shared.preferences.displaySeconds then
                        Duration.toLongString

                    else
                        Duration.toShortString
                   )

        _ ->
            []


timeLeftTitle : MobName -> DurationStringParts -> String
timeLeftTitle mob action =
    (case action of
        [] ->
            ""

        _ ->
            String.join " " action ++ " | "
    )
        ++ Model.MobName.print mob
        ++ " | Mob Time"
