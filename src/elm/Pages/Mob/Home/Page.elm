module Pages.Mob.Home.Page exposing
    ( AlarmState
    , Model
    , Msg(..)
    , Tab(..)
    , init
    , jsEventMapping
    , subscriptions
    , turnRefreshRate
    , update
    , view
    )

import Css
import Effect exposing (Effect)
import Html.Styled as Html exposing (..)
import Html.Styled.Attributes as Attr
import Html.Styled.Events as Evts exposing (onClick)
import Js.Commands
import Js.Events
import Js.EventsMapping exposing (EventsMapping)
import Lib.Duration as Duration
import Model.Clock as Clock exposing (ClockState(..))
import Model.Events
import Model.Mob
import Model.MobName exposing (MobName)
import Pages.Mob.Routing
import Pages.Mob.Tabs.Dev
import Pages.Mob.Tabs.Home
import Pages.Mob.Tabs.Mobbers
import Random
import Routing
import Shared exposing (Shared)
import Sounds
import Task
import Time
import UI.Button.View
import UI.CircularProgressBar
import UI.Color as Color
import UI.Column as Column
import UI.Css
import UI.Icons.Ion
import UI.Icons.Tape
import UI.Icons.Tea
import UI.Link.IconLink
import UI.Modal.View
import UI.Palettes as Palettes
import UI.Rem as Rem
import UI.Space as Space
import UI.Text as Text
import UI.Typography.Typography as Typography
import View exposing (View)



-- MODEL


type AlarmState
    = Playing
    | Stopped
    | Standby


type Tab
    = Main
    | Mobbers
    | Dev


type alias Model =
    { mobbersSettings : Pages.Mob.Tabs.Mobbers.Model
    , now : Time.Posix
    , tab : Tab
    , alarm : AlarmState
    }


init : Shared -> MobName -> ( Model, Effect Shared.Msg Msg )
init shared name =
    let
        redirection =
            if shared.soundOn then
                Effect.none

            else
                Shared.pushUrl shared <|
                    Routing.Mob
                        { subRoute = Pages.Mob.Routing.Profile
                        , name = name
                        }
    in
    ( { mobbersSettings = Pages.Mob.Tabs.Mobbers.init
      , now = shared.lastKnownTime
      , tab = Main
      , alarm = Standby
      }
    , redirection
    )



-- UPDATE


type Msg
    = StartWith ( Time.Posix, Sounds.Sound )
    | TimePassed Time.Posix Model.Mob.TimePassedResult
    | GotMainTabMsg Pages.Mob.Tabs.Home.Msg
    | GotMobbersSettingsMsg Pages.Mob.Tabs.Mobbers.Msg
    | SwitchTab Tab
    | StopSound
    | AlarmEnded
    | StopPomodoro
    | StartTurn
    | StopTurn


update : Shared -> Model.Mob.Mob -> Msg -> Model -> ( Model, Effect Shared.Msg Msg )
update shared mob msg model =
    case msg of
        GotMainTabMsg subMsg ->
            ( model
            , Pages.Mob.Tabs.Home.update subMsg
                |> Cmd.map GotMainTabMsg
                |> Effect.fromCmd
            )

        GotMobbersSettingsMsg subMsg ->
            let
                ( updated, command ) =
                    Pages.Mob.Tabs.Mobbers.update subMsg mob.mobbers mob.name model.mobbersSettings
            in
            ( { model | mobbersSettings = updated }
            , Effect.map GotMobbersSettingsMsg command
            )

        SwitchTab tab ->
            ( { model | tab = tab }
            , Effect.none
            )

        TimePassed now timePassedResult ->
            let
                ( alarm, alarmEffect ) =
                    case timePassedResult.turnEvent of
                        Clock.Ended ->
                            ( Playing, Js.Commands.send Js.Commands.SoundAlarm |> Effect.fromCmd )

                        Clock.Continued ->
                            ( model.alarm, Effect.none )
            in
            ( { model
                | now = now
                , alarm = alarm
              }
            , Effect.batch
                [ alarmEffect
                , Effect.fromCmd <|
                    Js.Commands.send <|
                        Js.Commands.ChangeTitle <|
                            String.join " | " <|
                                List.filter (not << String.isEmpty)
                                    [ String.join " " <|
                                        timeLeftString shared now mob.clock
                                    , Model.MobName.print mob.name
                                    , "Mob Time"
                                    ]
                ]
            )

        StopSound ->
            ( { model | alarm = Stopped }
            , Effect.js Js.Commands.StopAlarm
            )

        AlarmEnded ->
            ( { model | alarm = Stopped }
            , Effect.fromCmd <| Cmd.none
            )

        StopPomodoro ->
            ( model
            , Model.Events.PomodoroStopped
                |> Model.Events.MobEvent mob.name
                |> Effect.share
            )

        StartTurn ->
            ( model
            , Time.now
                |> Task.map
                    (\now -> ( now, selectSound now mob.soundProfile ))
                |> Task.perform StartWith
                |> Effect.fromCmd
            )

        StartWith ( now, sound ) ->
            ( { model | now = now }
            , Model.Events.Started
                { time = now
                , alarm = sound
                , length = mob.turnLength
                }
                |> Model.Events.Clock
                |> Model.Events.MobEvent mob.name
                |> Effect.share
            )

        StopTurn ->
            ( model
            , Model.Events.Clock Model.Events.Stopped
                |> Model.Events.MobEvent mob.name
                |> Effect.share
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
subscriptions _ =
    Sub.none



-- TODO get rid of that


jsEventMapping : EventsMapping Msg
jsEventMapping =
    Js.EventsMapping.batch
        [ Js.EventsMapping.create <|
            [ Js.Events.EventMessage "AlarmEnded" (always AlarmEnded)
            ]
        ]



-- VIEW


view : Shared -> Model.Mob.Mob -> Model -> View Msg
view shared mob model =
    { title = String.join " " <| timeLeftString shared model.now mob.clock
    , modal =
        case ( model.alarm, mob.clock, mob.pomodoro ) of
            ( Playing, _, _ ) ->
                Just musicModal

            ( _, Clock.Off, Clock.On pomodoro ) ->
                if Duration.secondsBetween model.now pomodoro.end <= 0 then
                    Just breakModal

                else
                    Nothing

            _ ->
                Nothing
    , body = body shared mob model
    }


musicModal : UI.Modal.View.Modal Msg
musicModal =
    { onClose = StopSound
    , content =
        Column.column
            [ Attr.css UI.Css.center ]
            [ Column.Gap <| Rem.Rem 2 ]
            [ UI.Icons.Tape.display
                { size = Rem.Rem 10
                , color = Palettes.monochrome.on.background
                }
            , Text.h2 [] "Turn ended !"
            , UI.Button.View.button [ Attr.css [ Css.width <| Css.pct 100 ] ]
                { content = UI.Button.View.Both { icon = UI.Icons.Ion.mute, text = "Stop music" }
                , variant = UI.Button.View.Primary
                , size = UI.Button.View.L
                , action = UI.Button.View.OnPress <| Just StopSound
                }
            ]
    }


breakModal : UI.Modal.View.Modal Msg
breakModal =
    { onClose = StopPomodoro
    , content =
        Column.column
            [ Attr.css UI.Css.center ]
            [ Column.Gap <| Rem.Rem 2 ]
            [ Text.h2 [] "It's time for a break!"
            , UI.Icons.Tea.display
                { size = Rem.Rem 10
                , color = Palettes.monochrome.on.background
                }
            , Html.p
                [ Attr.css [ Css.textAlign Css.justify ] ]
                [ Html.text "Boost your productivity by taking a good break." ]
            , UI.Button.View.button [ Attr.css [ Css.width <| Css.pct 100 ] ]
                { content = UI.Button.View.Both { icon = UI.Icons.Ion.check, text = "Break over" }
                , variant = UI.Button.View.Primary
                , size = UI.Button.View.L
                , action = UI.Button.View.OnPress <| Just StopPomodoro
                }
            ]
    }


body : Shared -> Model.Mob.Mob -> Model -> Html Msg
body shared mob model =
    div
        [ Attr.class "container"
        , Attr.css
            [ Css.position Css.relative
            ]
        ]
        [ clockArea mob model
        , nav []
            ([ button
                [ onClick <| SwitchTab Main
                , Attr.classList [ ( "active", model.tab == Main ) ]
                , Attr.title "Home"
                ]
                [ UI.Icons.Ion.home
                    { size = Rem.Rem 1.4
                    , color = Palettes.monochrome.on.surface
                    }
                ]
             , button
                [ onClick <| SwitchTab Mobbers
                , Attr.classList [ ( "active", model.tab == Mobbers ) ]
                , Attr.title "Mobbers"
                ]
                [ UI.Icons.Ion.people
                    { size = Rem.Rem 1.4
                    , color = Palettes.monochrome.on.surface
                    }
                ]
             ]
                ++ (if shared.devMode then
                        [ button
                            [ onClick <| SwitchTab Dev
                            , Attr.classList [ ( "active", model.tab == Dev ) ]
                            , Attr.title "Dev"
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
                Pages.Mob.Tabs.Home.view shared mob.name mob
                    |> Html.map GotMainTabMsg

            Mobbers ->
                Pages.Mob.Tabs.Mobbers.view mob model.mobbersSettings
                    |> Html.map GotMobbersSettingsMsg

            Dev ->
                Pages.Mob.Tabs.Dev.view
        ]


clockArea : Model.Mob.Mob -> Model -> Html Msg
clockArea mob model =
    let
        turnTime duration =
            Html.div
                [ Attr.css
                    [ Css.fontWeight Css.bold
                    , Typography.fontSize Typography.xl
                    ]
                ]
                [ Html.text <| Duration.digitalPrint duration
                ]

        pomodoroTime duration =
            Html.div
                [ Attr.css
                    [ Css.fontWeight Css.bold
                    , Typography.fontSize Typography.l
                    ]
                ]
                [ Html.text <| Duration.digitalPrint duration
                ]
    in
    header
        [ Attr.css
            [ Css.position Css.relative
            , Css.maxWidth Css.fitContent
            , Css.margin Css.auto
            , Css.displayFlex
            , Css.alignItems Css.flexStart
            , Css.paddingBottom (Css.rem 3)
            , Css.marginTop Space.s
            , Css.marginBottom Space.l
            ]
        ]
        [ displayClock []
            { state = mob.clock
            , now = model.now
            , messages =
                { onStart = Just StartTurn
                , onStop = StopTurn
                }
            , content =
                Html.div
                    [ Attr.css
                        [ Css.lineHeight <| Css.num 1
                        , Css.transform <| Css.translateY <| Css.pct 6
                        ]
                    ]
                    (case mob.clock of
                        Clock.On on ->
                            let
                                timeLeft =
                                    Duration.between model.now on.end
                            in
                            [ turnTime timeLeft
                            , Html.div []
                                [ Html.text <|
                                    if Duration.toMillis timeLeft > 0 then
                                        "Left in turn"

                                    else
                                        "Overtime"
                                ]
                            ]

                        Clock.Off ->
                            [ Html.text "Start a turn"
                            , turnTime mob.turnLength
                            , UI.Icons.Ion.play
                                { size = Rem.Rem 3
                                , color = Palettes.monochrome.on.background
                                }
                            ]
                    )
            , style =
                { strokeWidth = Rem.Rem 0.4
                , diameter = Rem.Rem 9
                }
            }
        , displayClock
            [ Attr.css
                [ Css.marginTop <| Css.rem 6
                ]
            ]
            { state = mob.pomodoro
            , now = model.now
            , messages =
                { onStart = Nothing
                , onStop = StopPomodoro
                }
            , content =
                Html.div
                    [ Attr.css
                        [ Css.lineHeight <| Css.num 1
                        , Css.transform <| Css.translateY <| Css.pct -10
                        ]
                    ]
                    (UI.Icons.Tea.display
                        { size = Rem.Rem 2
                        , color = Palettes.monochrome.on.background
                        }
                        :: (case mob.pomodoro of
                                Clock.On on ->
                                    [ pomodoroTime <| Duration.between model.now on.end
                                    , Html.div
                                        [ Attr.css
                                            [ Typography.fontSize Typography.s
                                            ]
                                        ]
                                        [ Html.text "Until break" ]
                                    ]

                                Clock.Off ->
                                    [ pomodoroTime mob.pomodoroLength
                                    , Html.text "Pomodoro"
                                    ]
                           )
                    )
            , style =
                { strokeWidth = Rem.Rem 0.2
                , diameter = Rem.Rem 7
                }
            }
        , UI.Link.IconLink.view
            [ Attr.css
                [ Css.position Css.absolute
                , Css.bottom <| Css.pct 10
                , Css.left <| Css.pct 32
                ]
            ]
            { target =
                Routing.toUrl <|
                    Routing.Mob
                        { subRoute = Pages.Mob.Routing.Invite
                        , name = mob.name
                        }
            , color = Palettes.monochrome.on.background
            , text = "Invite"
            , icon = UI.Icons.Ion.share
            }
        , UI.Link.IconLink.view
            [ Attr.css
                [ Css.position Css.absolute
                , Css.top <| Css.pct 5
                , Css.left <| Css.pct 66
                ]
            ]
            { target =
                Routing.toUrl <|
                    Routing.Mob
                        { subRoute = Pages.Mob.Routing.Settings
                        , name = mob.name
                        }
            , color = Palettes.monochrome.on.background
            , text = "Settings"
            , icon = UI.Icons.Ion.settings
            }
        , UI.Link.IconLink.view
            [ Attr.css
                [ Css.position Css.absolute
                , Css.bottom <| Css.pct 10
                , Css.left <| Css.pct 9
                ]
            ]
            { target =
                Routing.toUrl <|
                    Routing.Mob
                        { subRoute = Pages.Mob.Routing.Profile
                        , name = mob.name
                        }
            , color = Palettes.monochrome.on.background
            , text = "Profile"
            , icon = UI.Icons.Ion.user
            }
        ]


displayClock :
    List (Html.Attribute Msg)
    ->
        { state : Clock.ClockState
        , now : Time.Posix
        , messages :
            { onStart : Maybe Msg
            , onStop : Msg
            }
        , content : Html.Html Msg
        , style :
            { strokeWidth : Rem.Rem
            , diameter : Rem.Rem
            }
        }
    -> Html Msg
displayClock attributes { state, now, style, messages, content } =
    Html.div
        (Attr.css
            [ Css.position Css.relative
            , Css.maxWidth Css.fitContent
            ]
            :: attributes
        )
        [ UI.CircularProgressBar.draw
            { colors =
                { main = Palettes.monochrome.on.background
                , background = Palettes.monochrome.on.background |> Color.lighten 0.9
                , border = Palettes.monochrome.on.background |> Color.lighten 0.7
                }
            , strokeWidth = style.strokeWidth
            , diameter = style.diameter
            , progress = Clock.ratio now state
            , refreshRate = turnRefreshRate |> Duration.multiply 2
            }
        , Html.button
            [ case state of
                Clock.On _ ->
                    Evts.onClick messages.onStop

                Clock.Off ->
                    case messages.onStart of
                        Just msg ->
                            Evts.onClick msg

                        Nothing ->
                            Attr.disabled True
            , Attr.css
                [ Css.backgroundColor Css.transparent
                , Css.position Css.absolute
                , Css.width <| Css.pct 100
                , Css.height <| Css.pct 100
                , Css.overflow Css.hidden
                , Css.top Css.zero
                , Css.left Css.zero
                , Css.borderRadius <| Css.pct 50
                , Css.color <| Color.toElmCss <| Palettes.monochrome.on.background
                , Css.hover [ Css.backgroundColor Css.transparent ]
                , Css.disabled
                    [ Css.hover [ Css.backgroundColor Css.transparent ]
                    , Css.opacity <| Css.num 1
                    ]
                ]
            ]
            [ Html.div
                [ Attr.css
                    (UI.Css.center
                        ++ [ Css.displayFlex
                           , Css.flexDirection Css.column
                           , Css.alignItems Css.center
                           , Css.width <| Css.pct 100
                           ]
                    )
                ]
                [ content
                ]
            ]
        , case state of
            Clock.On _ ->
                UI.Button.View.button
                    [ Attr.css
                        [ Css.position Css.absolute
                        , Css.bottom Css.zero
                        , Css.left <| Css.pct 50
                        , Css.transform <| Css.translate2 (Css.pct -50) (Css.pct 40)
                        ]
                    ]
                    { content = UI.Button.View.Both { icon = UI.Icons.Ion.stop, text = "Stop" }
                    , variant = UI.Button.View.Primary
                    , size = UI.Button.View.S
                    , action = UI.Button.View.OnPress <| Just messages.onStop
                    }

            Clock.Off ->
                Html.span [] []
        ]


timeLeftString : Shared -> Time.Posix -> Clock.ClockState -> Duration.DurationStringParts
timeLeftString shared now clock =
    case clock of
        On on ->
            Duration.between now on.end
                |> (if shared.preferences.displaySeconds then
                        Duration.toLongString

                    else
                        Duration.toShortString
                   )

        _ ->
            []
