module Pages.Mob.Home.Page exposing
    ( ActionDescription
    , AlarmState
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
import Html.Styled.Attributes as Attr exposing (class, classList, css, id, title)
import Html.Styled.Events exposing (onClick)
import Js.Commands
import Js.Events
import Js.EventsMapping exposing (EventsMapping)
import Lib.Duration as Duration exposing (DurationStringParts)
import Model.Clock as Clock exposing (ClockState(..))
import Model.Events
import Model.Mob
import Model.MobName exposing (MobName)
import Pages.Mob.Routing
import Pages.Mob.Tabs.Clocks
import Pages.Mob.Tabs.Dev
import Pages.Mob.Tabs.Home
import Pages.Mob.Tabs.Mobbers
import Random
import Routing
import Shared exposing (Shared)
import Sounds
import Svg.Styled exposing (Svg)
import Task
import Time
import UI.Button.View
import UI.CircularProgressBar
import UI.Color as Color
import UI.Column as Column
import UI.Css
import UI.Icons
import UI.Icons.Ion
import UI.Icons.Tape
import UI.Icons.Tea
import UI.Link.IconLink
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
      , now = Time.millisToPosix 0
      , tab = Main
      , alarm = Standby
      }
    , redirection
    )



-- UPDATE


type Msg
    = ShareEvent Model.Events.MobEvent
    | StartClicked
    | StartWith ( Time.Posix, Sounds.Sound )
    | TimePassed Time.Posix Model.Mob.TimePassedResult
    | GotMainTabMsg Pages.Mob.Tabs.Home.Msg
    | GotClockSettingsMsg Pages.Mob.Tabs.Clocks.Msg
    | GotMobbersSettingsMsg Pages.Mob.Tabs.Mobbers.Msg
    | SwitchTab Tab
    | StopSound
    | AlarmEnded
    | StopPomodoro


update : Shared -> Model.Mob.Mob -> Msg -> Model -> ( Model, Effect Shared.Msg Msg )
update shared mob msg model =
    case msg of
        ShareEvent event ->
            ( model
            , Effect.share event
            )

        StartClicked ->
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

        GotClockSettingsMsg subMsg ->
            ( model
            , Pages.Mob.Tabs.Clocks.update subMsg mob.name
                |> Effect.map GotClockSettingsMsg
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
                                        timeLeftString shared now mob
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
    let
        action =
            detectAction shared model.now mob
    in
    { title = String.join " " <| timeLeftString shared model.now mob
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
    , body = body shared mob model action
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
                { height = Rem.Rem 10
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


body : Shared -> Model.Mob.Mob -> Model -> ActionDescription -> Html Msg
body shared mob model action =
    div
        [ class "container"
        , Attr.css
            [ Css.position Css.relative
            ]
        ]
        [ clockArea mob model action
        , UI.Link.IconLink.view
            [ Attr.css
                [ Css.position Css.absolute
                , Css.top <| Css.rem 10
                , Css.left <| Css.calc (Css.pct 50) Css.minus (Css.rem 5)
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
                , Css.top <| Css.rem 10
                , Css.right <| Css.calc (Css.pct 50) Css.minus (Css.rem 5)
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
                , Css.top <| Css.rem 11.2
                , Css.right <| Css.calc (Css.pct 50) Css.minus (Css.rem 1.4)
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
        , nav []
            ([ button
                [ onClick <| SwitchTab Main
                , classList [ ( "active", model.tab == Main ) ]
                , title "Home"
                ]
                [ UI.Icons.Ion.home
                    { size = Rem.Rem 1.4
                    , color = Palettes.monochrome.on.surface
                    }
                ]
             , button
                [ onClick <| SwitchTab Clock
                , classList [ ( "active", model.tab == Clock ) ]
                , title "Clock Settings"
                ]
                [ UI.Icons.Ion.clock
                    { size = Rem.Rem 1.4
                    , color = Palettes.monochrome.on.surface
                    }
                ]
             , button
                [ onClick <| SwitchTab Mobbers
                , classList [ ( "active", model.tab == Mobbers ) ]
                , title "Mobbers"
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
                Pages.Mob.Tabs.Home.view shared mob.name mob
                    |> Html.map GotMainTabMsg

            Clock ->
                Pages.Mob.Tabs.Clocks.view shared model.now mob
                    |> Html.map GotClockSettingsMsg

            Mobbers ->
                Pages.Mob.Tabs.Mobbers.view mob model.mobbersSettings
                    |> Html.map GotMobbersSettingsMsg

            Dev ->
                Pages.Mob.Tabs.Dev.view
        ]


clockArea : Model.Mob.Mob -> Model -> ActionDescription -> Html Msg
clockArea mob model action =
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
                    , progress = Clock.ratio model.now mob.pomodoro
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
                        , progress = Clock.ratio model.now mob.clock
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
                        Color.opactity 0 <|
                            Palettes.monochrome.background
                ]
            ]
        ]
        [ div [ Attr.id "action-icon" ] [ action.icon ]
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


detectAction : Shared -> Time.Posix -> Model.Mob.Mob -> ActionDescription
detectAction shared now mob =
    let
        timeLeft =
            timeLeftString shared now mob
    in
    case mob.clock of
        On _ ->
            { icon =
                UI.Icons.Ion.stop
                    { size = Rem.Rem 1
                    , color = Palettes.monochrome.on.background
                    }
            , message =
                Model.Events.Clock Model.Events.Stopped
                    |> Model.Events.MobEvent mob.name
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


timeLeftString : Shared -> Time.Posix -> Model.Mob.Mob -> Duration.DurationStringParts
timeLeftString shared now mob =
    case mob.clock of
        On on ->
            Duration.between now on.end
                |> (if shared.preferences.displaySeconds then
                        Duration.toLongString

                    else
                        Duration.toShortString
                   )

        _ ->
            []
