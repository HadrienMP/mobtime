module Timer exposing (..)

import Circle
import Html exposing (Html, audio, button, header, i, section, span, text)
import Html.Attributes exposing (class, src)
import Html.Events exposing (onClick)
import Json.Encode
import Ratio exposing (Ratio)
import Settings.Dev
import Settings.Timer
import Sounds
import Svg exposing (svg)
import Svg.Attributes as Svg


init : Model
init =
    { turn = Off
    , state = NotPlaying
    , sound = Sounds.default
    }


type alias Model =
    { turn : Turn
    , state : SoundStatus
    , sound : Sounds.Sound
    }


type Turn
    = Off
    | On { timeLeft : Int, length : Int }


type SoundStatus
    = Playing
    | NotPlaying


type Msg
    = StartRequest
    | StopRequest
    | StopSoundRequest


timePassed : Model -> Settings.Dev.Speed -> Model
timePassed model speed =
    case model.turn of
        On on ->
            { model | turn = On { on | timeLeft = on.timeLeft - Settings.Dev.seconds speed } }

        Off ->
            model

turnOff : Model -> (Json.Encode.Value -> Cmd Msg) -> (Model, Cmd Msg)
turnOff model soundCommands =
    ( { model | turn = Off, state = Playing }
    , soundCommands playCommand
    )

playCommand : Json.Encode.Value
playCommand =
    Json.Encode.object
        [ ( "name", Json.Encode.string "play" )
        , ( "data", Json.Encode.object [] )
        ]


update : Model -> Msg -> (Json.Encode.Value -> Cmd Msg) -> ( Model, Cmd Msg )
update model msg soundCommands =
    case msg of

        StartRequest ->
            ( { model | turn = On { timeLeft = model.timerSettings.turnLength * 60, length = model.timerSettings.turnLength } }
            , Random.generate PickedSound <| Sounds.pick model.soundSettings.profile
            )

        StopRequest ->
            ( { model | turn = Off }
            , Cmd.none
            )


type Action
    = Start
    | Stop
    | StopSound


actionMessage : Action -> Msg
actionMessage action =
    case action of
        Start ->
            StartRequest

        Stop ->
            StopRequest

        StopSound ->
            StopSoundRequest


view : Model -> Settings.Timer.Model -> Html Msg
view model timerSettings =
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
    header []
        [ section []
            [ svg
                [ Svg.width <| String.fromInt totalWidth
                , Svg.height <| String.fromInt totalWidth
                ]
                (Circle.drawWithoutInsideBorder pomodoroCircle Ratio.full
                    ++ Circle.draw mobCircle (ratio model)
                )
            , button
                [ onClick <| actionMessage <| actionOf model
                , class <| turnToString model.turn
                ]
                [ span [] [ text <| timeLeft model timerSettings ]
                , actionIcon <| actionOf model
                ]
            ]
        , audio [ src <| "/sound/" ++ model.sound ] []
        ]


turnToString : Turn -> String
turnToString turn =
    case turn of
        On _ ->
            "on"

        Off ->
            "off"


timeLeft : Model -> Settings.Timer.Model -> String
timeLeft model timerSettings =
    case model.turn of
        On t ->
            let
                floatMinutes =
                    toFloat t.timeLeft / 60.0

                intMinutes =
                    floor floatMinutes

                secondsLeft =
                    t.timeLeft - (floor floatMinutes * 60)

                minutesText =
                    if intMinutes /= 0 then
                        String.fromInt intMinutes ++ " min "

                    else
                        ""

                secondsText =
                    if secondsLeft /= 0 then
                        String.fromInt secondsLeft ++ " " ++ "s"

                    else
                        ""
            in
            if timerSettings.displaySeconds || t.timeLeft < 60 then
                minutesText ++ secondsText

            else
                (String.fromInt <| ceiling floatMinutes) ++ " min"

        Off ->
            ""


actionOf : Model -> Action
actionOf model =
    case ( model.turn, model.state ) of
        ( On _, NotPlaying ) ->
            Stop

        ( On _, Playing ) ->
            StopSound

        ( Off, Playing ) ->
            StopSound

        ( Off, NotPlaying ) ->
            Start


actionIcon : Action -> Html msg
actionIcon action =
    case action of
        Start ->
            i [ class "fas fa-play" ] []

        Stop ->
            i [ class "fas fa-square" ] []

        StopSound ->
            i [ class "fas fa-volume-mute" ] []


ratio : Model -> Ratio
ratio model =
    case model.turn of
        On turn ->
            (1 - (toFloat (turn.timeLeft - 1) / (toFloat turn.length * 60)))
                |> Debug.log ""
                |> Ratio.from

        Off ->
            Ratio.full
