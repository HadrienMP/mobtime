module Pages.Mob exposing (..)

import Browser.Events exposing (onKeyUp)
import Css exposing (absolute)
import Html.Styled as Html exposing (..)
import Html.Styled.Attributes exposing (class, classList, css, id, title)
import Html.Styled.Events exposing (onClick)
import Js.Commands
import Js.Events
import Js.EventsMapping as EventsMapping exposing (EventsMapping)
import Json.Decode
import Lib.Duration as Duration exposing (DurationStringParts)
import Lib.Konami as Konami exposing (Konami)
import Lib.UpdateResult as UpdateResult exposing (UpdateResult)
import Model.Clock as Clock exposing (ClockState(..))
import Model.Events
import Model.MobName exposing (MobName)
import Model.State
import Pages.Mob.Tabs.Clocks
import Pages.Mob.Tabs.Dev
import Pages.Mob.Tabs.Home
import Pages.Mob.Tabs.Mobbers
import Pages.Mob.Tabs.Share
import Pages.Mob.Tabs.Sound
import Peers.Sync.Adapter
import Peers.Sync.Core exposing (PeerId)
import Random
import Socket
import Sounds
import Svg.Styled exposing (Svg)
import Task
import Time
import UI.CircularProgressBar
import UI.Color
import UI.Icons
import UI.Icons.Ion
import UI.Palettes
import UI.Rem
import Url
import UserPreferences
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
    | Share
    | Dev


type alias Model =
    { name : MobName
    , shared : Model.State.State
    , mobbersSettings : Pages.Mob.Tabs.Mobbers.Model
    , clockSettings : Pages.Mob.Tabs.Clocks.Model
    , soundSettings : Pages.Mob.Tabs.Sound.Model
    , clockSync : Peers.Sync.Adapter.Model
    , alarm : AlarmState
    , now : Time.Posix
    , tab : Tab
    , dev : Bool
    , konami : Konami
    , peerId : Maybe PeerId
    }


init : MobName -> UserPreferences.Model -> ( Model, Cmd Msg )
init name preferences =
    let
        ( clockSync, clockSyncCommand ) =
            Peers.Sync.Adapter.init name
    in
    ( { name = name
      , shared = Model.State.init
      , mobbersSettings = Pages.Mob.Tabs.Mobbers.init
      , clockSettings = Pages.Mob.Tabs.Clocks.init
      , soundSettings = Pages.Mob.Tabs.Sound.init preferences.volume
      , clockSync = clockSync
      , alarm = Standby
      , now = Time.millisToPosix 0
      , tab = Main
      , dev = False
      , konami = Konami.empty
      , peerId = Nothing
      }
    , Cmd.batch
        [ Socket.joinRoom <| Model.MobName.print name
        , Time.now |> Task.perform TimePassed
        , Cmd.map GotClockSyncMsg clockSyncCommand
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
    | GotShareTabMsg Pages.Mob.Tabs.Share.Msg
    | GotMobbersSettingsMsg Pages.Mob.Tabs.Mobbers.Msg
    | GotSoundSettingsMsg Pages.Mob.Tabs.Sound.Msg
    | GotClockSyncMsg Peers.Sync.Adapter.Msg
    | SwitchTab Tab
    | KeyPressed Keystroke
    | GotSocketId PeerId


timePassed : Time.Posix -> Model -> ( Model, Cmd Msg )
timePassed now model =
    let
        timePassedResult =
            Model.State.timePassed now model.shared

        toto =
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
        , shared = timePassedResult.updated
      }
    , Cmd.batch
        [ toto
        , Js.Commands.send <| Js.Commands.ChangeTitle <| timeLeftTitle <| timeLeftString model
        ]
    )


update : Msg -> Model -> UpdateResult Model Msg
update msg model =
    case msg of
        ShareEvent event ->
            { model = model
            , command = Model.Events.sendEvent <| Model.Events.mobEventToJson event
            , toasts = []
            }

        ReceivedEvent event ->
            let
                ( shared, command ) =
                    Model.State.evolve event model.shared
            in
            { model =
                { model
                    | shared = shared
                    , alarm =
                        -- Handle alarm (command) as separate from the evolve method ?
                        case event of
                            Model.Events.Clock (Model.Events.Started _) ->
                                Stopped

                            _ ->
                                model.alarm
                }
            , command = command
            , toasts = []
            }

        ReceivedHistory eventsResults ->
            let
                ( shared, command ) =
                    Model.State.evolveMany eventsResults model.shared
            in
            { model = { model | shared = shared }
            , command = command
            , toasts = []
            }

        StartClicked ->
            { model = model
            , command =
                Time.now
                    |> Task.map
                        (\now -> ( now, selectSound now model.shared.soundProfile ))
                    |> Task.perform StartWith
            , toasts = []
            }

        StartWith ( now, sound ) ->
            { model = { model | now = now }
            , command =
                Model.Events.Started
                    { time = now
                    , alarm = sound
                    , length =
                        Duration.div model.shared.turnLength <|
                            if model.dev then
                                20

                            else
                                1
                    }
                    |> Model.Events.Clock
                    |> Model.Events.MobEvent model.name
                    |> Model.Events.mobEventToJson
                    |> Model.Events.sendEvent
            , toasts = []
            }

        StopSound ->
            { model = { model | alarm = Stopped }
            , command = Js.Commands.send Js.Commands.StopAlarm
            , toasts = []
            }

        AlarmEnded ->
            { model = { model | alarm = Stopped }
            , command = Cmd.none
            , toasts = []
            }

        GotMainTabMsg subMsg ->
            { model = model
            , command = Pages.Mob.Tabs.Home.update subMsg |> Cmd.map GotMainTabMsg
            , toasts = []
            }

        GotMobbersSettingsMsg subMsg ->
            let
                mobbersResult =
                    Pages.Mob.Tabs.Mobbers.update subMsg model.shared.mobbers model.name model.mobbersSettings
            in
            { model =
                { model
                    | mobbersSettings = mobbersResult.model
                }
            , command = Cmd.map GotMobbersSettingsMsg mobbersResult.command
            , toasts = mobbersResult.toasts
            }

        SwitchTab tab ->
            { model = { model | tab = tab }
            , command = Cmd.none
            , toasts = []
            }

        GotShareTabMsg subMsg ->
            { model = model
            , command = Pages.Mob.Tabs.Share.update subMsg |> Cmd.map GotShareTabMsg
            , toasts = []
            }

        GotClockSettingsMsg subMsg ->
            let
                ( clockSettings, command ) =
                    Pages.Mob.Tabs.Clocks.update subMsg model.clockSettings model.name
            in
            { model = { model | clockSettings = clockSettings }
            , command = Cmd.map GotClockSettingsMsg command
            , toasts = []
            }

        GotSoundSettingsMsg subMsg ->
            let
                ( soundSettings, command ) =
                    Pages.Mob.Tabs.Sound.update subMsg model.soundSettings
            in
            { model = { model | soundSettings = soundSettings }
            , command = Cmd.map GotSoundSettingsMsg command
            , toasts = []
            }

        KeyPressed { key } ->
            { model =
                { model
                    | dev = xor model.dev <| Konami.isActivated model.konami
                    , konami = Konami.add key model.konami
                }
            , command = Cmd.none
            , toasts = []
            }

        GotClockSyncMsg sub ->
            Peers.Sync.Adapter.update sub model.clockSync model.now
                |> UpdateResult.map
                    (\m -> { model | clockSync = m })
                    GotClockSyncMsg

        GotSocketId peerId ->
            UpdateResult.fromModel { model | peerId = Just peerId }

        TimePassed now ->
            let
                ( updated, command ) =
                    timePassed now model
            in
            { model = updated
            , toasts = []
            , command = command
            }


selectSound : Time.Posix -> Sounds.Profile -> Sounds.Sound
selectSound now profile =
    Random.step (Sounds.pick profile)
        (now
            |> Time.posixToMillis
            |> Random.initialSeed
        )
        |> Tuple.first



-- SUBSCRIPTIONS


type alias Keystroke =
    { key : String
    , ctrl : Bool
    , alt : Bool
    , shift : Bool
    }


turnRefreshRate : Duration.Duration
turnRefreshRate =
    Duration.ofMillis 500


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Model.Events.receiveOne <| Model.Events.fromJson >> ReceivedEvent
        , Model.Events.receiveHistory <| List.map Model.Events.fromJson >> ReceivedHistory
        , Sub.map GotClockSyncMsg Peers.Sync.Adapter.subscriptions
        , case ( Clock.isOn model.shared.clock, Clock.isOn model.shared.pomodoro ) of
            ( True, _ ) ->
                Time.every (Duration.toMillis turnRefreshRate |> toFloat) TimePassed

            ( False, True ) ->
                Time.every 2000 TimePassed

            _ ->
                Sub.none
        , onKeyUp <|
            Json.Decode.map KeyPressed <|
                Json.Decode.map4 Keystroke
                    (Json.Decode.field "key" Json.Decode.string)
                    (Json.Decode.field "ctrlKey" Json.Decode.bool)
                    (Json.Decode.field "altKey" Json.Decode.bool)
                    (Json.Decode.field "shiftKey" Json.Decode.bool)
        ]


jsEventMapping : EventsMapping Msg
jsEventMapping =
    EventsMapping.batch
        [ EventsMapping.create <|
            [ Js.Events.EventMessage "AlarmEnded" (always AlarmEnded)
            , Js.Events.EventMessage "GotSocketId" GotSocketId
            ]
        , EventsMapping.map GotClockSyncMsg Peers.Sync.Adapter.jsEventMapping
        ]



-- VIEW


view : Model -> Url.Url -> View Msg
view model url =
    let
        action =
            detectAction model
    in
    { title = timeLeftTitle action.timeLeft
    , body = body model url action
    }


body : Model -> Url.Url -> ActionDescription -> List (Html Msg)
body model url action =
    [ div [ class "container" ]
        [ header []
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
                            { main = UI.Palettes.monochrome.surface |> UI.Color.lighten 6
                            , background = UI.Palettes.monochrome.surface |> UI.Color.lighten 12
                            , border = UI.Palettes.monochrome.surface |> UI.Color.lighten 10
                            }
                        , strokeWidth = UI.Rem.Rem 0.3
                        , diameter = UI.Rem.Rem 8.7
                        , progress = Clock.ratio model.now model.shared.pomodoro
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
                                { main = UI.Palettes.monochrome.surface
                                , background = UI.Palettes.monochrome.surface |> UI.Color.lighten 12
                                , border = UI.Palettes.monochrome.surface |> UI.Color.lighten 10
                                }
                            , strokeWidth = UI.Rem.Rem 0.5
                            , diameter = UI.Rem.Rem 7.8
                            , progress = Clock.ratio model.now model.shared.clock
                            , refreshRate = turnRefreshRate |> Duration.multiply 2
                            }
                        ]
                    , UI.Icons.style
                        { class = "action"
                        , size = UI.Rem.Rem 3
                        , colors =
                            { normal = UI.Palettes.monochrome.surface
                            , hover = UI.Palettes.monochrome.surface
                            }
                        }
                      <|
                        actionButton action
                    ]
                ]
            ]
        , nav []
            ([ button
                [ onClick <| SwitchTab Main
                , classList [ ( "active", model.tab == Main ) ]
                , title "Home"
                ]
                [ UI.Icons.Ion.home ]
             , button
                [ onClick <| SwitchTab Clock
                , classList [ ( "active", model.tab == Clock ) ]
                , title "Clock Settings"
                ]
                [ UI.Icons.Ion.clock ]
             , button
                [ onClick <| SwitchTab Mobbers
                , classList [ ( "active", model.tab == Mobbers ) ]
                , title "Mobbers"
                ]
                [ UI.Icons.Ion.people ]
             , button
                [ onClick <| SwitchTab Sound
                , classList [ ( "active", model.tab == Sound ) ]
                , title "Sound Settings"
                ]
                [ UI.Icons.Ion.sound ]
             , button
                [ onClick <| SwitchTab Share
                , classList [ ( "active", model.tab == Share ) ]
                , title "Share"
                ]
                [ UI.Icons.Ion.share ]
             ]
                ++ (if model.dev then
                        [ button
                            [ onClick <| SwitchTab Dev
                            , classList [ ( "active", model.tab == Dev ) ]
                            , title "Dev"
                            ]
                            [ UI.Icons.Ion.code ]
                        ]

                    else
                        []
                   )
            )
        , case model.tab of
            Main ->
                Pages.Mob.Tabs.Home.view model.name url model.shared
                    |> Html.map GotMainTabMsg

            Clock ->
                Pages.Mob.Tabs.Clocks.view model.clockSettings model.now model.shared
                    |> Html.map GotClockSettingsMsg

            Mobbers ->
                Pages.Mob.Tabs.Mobbers.view model.shared model.mobbersSettings
                    |> Html.map GotMobbersSettingsMsg

            Sound ->
                Pages.Mob.Tabs.Sound.view model.soundSettings model.name model.shared.soundProfile
                    |> Html.map GotSoundSettingsMsg

            Share ->
                Pages.Mob.Tabs.Share.view model.name url
                    |> Html.map GotShareTabMsg

            Dev ->
                Pages.Mob.Tabs.Dev.view model.clockSync
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
                UI.Color.toElmCss <|
                    UI.Color.opactity 0.5 <|
                        UI.Palettes.monochrome.background
            , Css.color <| UI.Color.toElmCss <| UI.Palettes.monochrome.surface
            , Css.hover
                [ Css.backgroundColor <|
                    UI.Color.toElmCss <|
                        UI.Color.opactity 0.8 <|
                            UI.Palettes.monochrome.background
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


centerXY : List Css.Style
centerXY =
    [ Css.position absolute
    , Css.top <| Css.pct 50
    , Css.left <| Css.pct 50
    , Css.transforms
        [ Css.translateX <| Css.pct -50
        , Css.translateY <| Css.pct -50
        ]
    ]


type alias ActionDescription =
    { icon : Svg Msg
    , message : Msg
    , timeLeft : DurationStringParts
    , class : String
    }


detectAction : Model -> ActionDescription
detectAction model =
    let
        timeLeft =
            timeLeftString model
    in
    case ( model.alarm, model.shared.clock, model.shared.pomodoro ) of
        ( Playing, _, _ ) ->
            { icon = UI.Icons.Ion.mute
            , message = StopSound
            , timeLeft = timeLeft
            , class = ""
            }

        ( _, On _, _ ) ->
            { icon = UI.Icons.Ion.stop
            , message =
                Model.Events.Clock Model.Events.Stopped
                    |> Model.Events.MobEvent model.name
                    |> ShareEvent
            , class = "on"
            , timeLeft = timeLeft
            }

        ( _, Off, On pomodoro ) ->
            if Duration.secondsBetween model.now pomodoro.end <= 0 then
                { icon = UI.Icons.Ion.coffee
                , message =
                    Model.Events.PomodoroStopped
                        |> Model.Events.MobEvent model.name
                        |> ShareEvent
                , class = ""
                , timeLeft = timeLeft
                }

            else
                { icon = UI.Icons.Ion.play
                , message = StartClicked
                , class = ""
                , timeLeft = timeLeft
                }

        ( _, Off, _ ) ->
            { icon = UI.Icons.Ion.play
            , message = StartClicked
            , class = ""
            , timeLeft = timeLeft
            }


timeLeftString : Model -> DurationStringParts
timeLeftString model =
    case model.shared.clock of
        On on ->
            Duration.between model.now on.end
                |> (if model.clockSettings.displaySeconds then
                        Duration.toLongString

                    else
                        Duration.toShortString
                   )

        _ ->
            []


timeLeftTitle : DurationStringParts -> String
timeLeftTitle action =
    case action of
        [] ->
            "Mob Time"

        _ ->
            String.join " " action ++ " | " ++ "Mob Time"
