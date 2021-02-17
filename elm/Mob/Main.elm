module Mob.Main exposing (..)

import Html exposing (Html, div, h2, header, section)
import Html.Attributes exposing (class, id)
import Mob.Action
import Mob.Clock.Circle as Circle
import Mob.Clock.Main as Clock
import Mob.Clock.Settings
import Mob.Lib.Ratio as Ratio exposing (Ratio)
import Mob.Sound.Main as Sound
import Mob.Tabs.Dev
import Mob.Tabs.Mobbers
import Mob.Tabs.Share
import Mob.Tabs.Tabs
import Svg exposing (Svg, svg)
import Svg.Attributes as Svg
import Time
import Url
import UserPreferences



-- MODEL


type alias Model =
    { name : String
    , tab : Mob.Tabs.Tabs.Tab
    , timerSettings : Mob.Clock.Settings.Model
    , dev : Mob.Tabs.Dev.Model
    , mobbers : Mob.Tabs.Mobbers.Model
    , mobClock : Clock.Model
    , sound : Sound.Model
    }


init : String -> UserPreferences.Model -> Model
init name userPreferences =
    { name = name
    , tab = Mob.Tabs.Tabs.timerTab
    , timerSettings = Mob.Clock.Settings.init
    , dev = Mob.Tabs.Dev.init
    , mobbers = Mob.Tabs.Mobbers.init
    , mobClock = Clock.Off
    , sound = Sound.init userPreferences.volume
    }



-- UPDATE


type Msg
    = TimePassed Time.Posix
    | ClockMsg Clock.Msg
    | SoundMsg Sound.Msg
    | TimerSettingsMsg Mob.Clock.Settings.Msg
    | DevSettingsMsg Mob.Tabs.Dev.Msg
    | MobbersSettingsMsg Mob.Tabs.Mobbers.Msg
    | TabsMsg Mob.Tabs.Tabs.Msg
    | ShareMsg Mob.Tabs.Share.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        TimePassed _ ->
            Clock.timePassed model.mobClock model.dev
                |> handleClockResult model

        ClockMsg clockMsg ->
            Clock.update model.timerSettings clockMsg
                |> handleClockResult model

        SoundMsg soundMsg ->
            Sound.update model.sound soundMsg
                |> Tuple.mapBoth
                    (\updated -> { model | sound = updated })
                    (Cmd.map SoundMsg)

        MobbersSettingsMsg mobberMsg ->
            Mob.Tabs.Mobbers.update mobberMsg model.mobbers
                |> Tuple.mapBoth
                    (\it -> { model | mobbers = it })
                    (Cmd.map MobbersSettingsMsg)

        TimerSettingsMsg timerMsg ->
            Mob.Clock.Settings.update timerMsg model.timerSettings
                |> Tuple.mapBoth
                    (\it -> { model | timerSettings = it })
                    (Cmd.map TimerSettingsMsg)

        DevSettingsMsg devMsg ->
            Mob.Tabs.Dev.update devMsg model.dev
                |> Tuple.mapBoth
                    (\dev -> { model | dev = dev })
                    (Cmd.map DevSettingsMsg)

        TabsMsg tabsMsg ->
            case tabsMsg of
                Mob.Tabs.Tabs.Clicked tab ->
                    ( { model | tab = tab }, Cmd.none )

        ShareMsg shareMsg ->
            ( model
            , Mob.Tabs.Share.update shareMsg
                |> Cmd.map ShareMsg
            )


handleClockResult : Model -> Clock.UpdateResult -> ( Model, Cmd Msg )
handleClockResult model clockResult =
    let
        soundResult =
            Sound.handleClockEvents model.sound clockResult.event

        mobbersResult =
            Mob.Tabs.Mobbers.handleClockEvents model.mobbers clockResult.event
    in
    ( { model
        | mobClock = clockResult.model
        , sound = soundResult.model
        , mobbers = mobbersResult.model
      }
    , Cmd.batch <|
        [ soundResult.command |> Cmd.map SoundMsg
        , clockResult.command |> Cmd.map ClockMsg
        , mobbersResult.command |> Cmd.map MobbersSettingsMsg
        ]
    )



-- SUBSCRIPTIONS


subscriptions : Sub Msg
subscriptions =
    Sub.batch
        [ Time.every 1000 TimePassed
        , Sound.subscriptions |> Sub.map SoundMsg
        ]



-- VIEW


view : Model -> Url.Url -> Html Msg
view model url =
    div
        [ id "mob", class "container" ]
        [ header []
            [ section []
                [ clockView model
                , Mob.Action.actionView
                    { clock = model.mobClock, sound = model.sound, clockSettings = model.timerSettings }
                    { clock = ClockMsg, sound = SoundMsg }
                ]
            ]
        , h2 [] [ Mob.Tabs.Share.shareButton url |> Html.map ShareMsg ]
        , Mob.Tabs.Tabs.navView model.tab |> Html.map TabsMsg
        , case model.tab.type_ of
            Mob.Tabs.Tabs.Timer ->
                Mob.Clock.Settings.view model.timerSettings
                    |> Html.map TimerSettingsMsg

            Mob.Tabs.Tabs.Mobbers ->
                Mob.Tabs.Mobbers.view model.mobbers
                    |> Html.map MobbersSettingsMsg

            Mob.Tabs.Tabs.Sound ->
                Sound.settingsView model.sound
                    |> Html.map SoundMsg

            Mob.Tabs.Tabs.Dev ->
                Mob.Tabs.Dev.view model.dev
                    |> Html.map DevSettingsMsg

            Mob.Tabs.Tabs.Share ->
                Mob.Tabs.Share.view
        ]


pageTitle model =
    Clock.humanReadableTimeLeft model.mobClock model.timerSettings
        |> List.foldr (++) ""
        |> (\it ->
                if String.isEmpty it then
                    ""

                else
                    it ++ " | "
           )
        |> (\it -> it ++ "Mob Time !")



-- CLOCK


clockView : Model -> Html Msg
clockView model =
    let
        totalWidth =
            220

        outerRadiant =
            104

        pomodoroCircle =
            Circle.Circle
                outerRadiant
                (Circle.Coordinates (outerRadiant + 6) (outerRadiant + 6))
                (Circle.Stroke 10 "#999")

        mobCircle =
            Circle.inside pomodoroCircle <| Circle.Stroke 18 "#666"
    in
    svg
        [ Svg.width <| String.fromInt totalWidth
        , Svg.height <| String.fromInt totalWidth
        ]
        (Circle.drawWithoutInsideBorder pomodoroCircle Ratio.full
            ++ Clock.view mobCircle model.mobClock
        )
