port module Main exposing (..)

import Browser
import Browser.Navigation as Nav
import Circle
import Html exposing (Html, a, audio, button, div, form, h2, i, input, label, li, nav, option, p, section, select, span, text, ul)
import Html.Attributes exposing (class, classList, for, href, id, placeholder, src, type_, value)
import Html.Events exposing (onClick)
import Json.Encode
import Random
import Ratio exposing (Ratio)
import Sounds
import Svg exposing (Svg, svg)
import Svg.Attributes as Svg
import Time
import Url



-- MAIN


main : Program String Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlChange = UrlChanged
        , onUrlRequest = LinkClicked
        }


port store : Json.Encode.Value -> Cmd msg


port soundCommands : String -> Cmd msg


port soundEnded : (String -> msg) -> Sub msg



-- MODEL


type TabType
    = Timer
    | Mobbers
    | Settings


type alias Tab =
    { type_ : TabType
    , url : String
    , name : String
    , icon : String
    }


timerPage : Tab
timerPage =
    Tab Timer "/timer" "Timer" "fa-clock"


pages : List Tab
pages =
    [ timerPage
    , Tab Mobbers "/mobbers" "Mobbers" "fa-users"
    , Tab Settings "/settings" "Settings" "fa-cog"
    ]


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


type alias Audio =
    { state : SoundStatus
    , sound : Sounds.Sound
    }


type SoundStatus
    = Playing
    | NotPlaying


type alias Model =
    { key : Nav.Key
    , url : Url.Url
    , tab : Tab
    , nickName : String
    , turn : Turn
    , audio : Audio
    }


type Turn
    = Off
    | On { timeLeft : Float, turnLength : Float }


init : String -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init nickname url key =
    ( { key = key
      , url = url
      , tab = pageFrom url |> Maybe.withDefault timerPage
      , nickName = nickname
      , turn = Off
      , audio =
            { state = NotPlaying
            , sound = Sounds.default
            }
      }
    , Cmd.none
    )


pageFrom : Url.Url -> Maybe Tab
pageFrom url =
    pages
        |> List.filter (\p -> p.url == url.path)
        |> List.head



-- UPDATE


type Msg
    = LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | TimePassed Time.Posix
    | StartRequest
    | StopRequest
    | PickedSound Sounds.Sound
    | SoundEnded String
    | StopSoundRequest


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LinkClicked urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Nav.pushUrl model.key (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        UrlChanged url ->
            ( { model | url = url, tab = pageFrom url |> Maybe.withDefault timerPage }
            , Cmd.none
            )

        TimePassed _ ->
            case model.turn of
                On turn ->
                    if turn.timeLeft == 1 then
                        ( { model | turn = Off, audio = { state = Playing, sound = model.audio.sound } }
                        , soundCommands "play"
                        )

                    else
                        ( { model | turn = On { turn | timeLeft = turn.timeLeft - 1 } }
                        , Cmd.none
                        )

                Off ->
                    ( model, Cmd.none )

        StartRequest ->
            ( { model | turn = On { timeLeft = 10, turnLength = 10 } }
            , Random.generate PickedSound Sounds.pick
            )

        StopRequest ->
            ( { model | turn = Off }
            , Cmd.none
            )

        PickedSound sound ->
            ( { model | audio = { state = NotPlaying, sound = sound } }
            , Cmd.none
            )

        SoundEnded _ ->
            ( { model | audio = { state = NotPlaying, sound = model.audio.sound } }
            , Cmd.none
            )

        StopSoundRequest ->
            ( { model | audio = { state = NotPlaying, sound = model.audio.sound } }
            , soundCommands "stop"
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ Time.every 1000 TimePassed
        , soundEnded SoundEnded
        ]



-- VIEW


view : Model -> Browser.Document Msg
view model =
    { title = "Mob Time !"
    , body =
        [ div
            [ id "container" ]
            [ nav [] <| navLinks model.url
            , case model.tab.type_ of
                Timer ->
                    timerView model

                Mobbers ->
                    mobbersView model

                Settings ->
                    settingsView model
            ]
        ]
    }


navLinks : Url.Url -> List (Html msg)
navLinks current =
    List.map
        (\page ->
            a
                [ href page.url, classList [ activeClass current page.url ] ]
                [ i [ class <| "fas " ++ page.icon ] [] ]
        )
        pages


activeClass : Url.Url -> String -> ( String, Bool )
activeClass current tabUrl =
    ( "active", current.path == tabUrl )


timerView : Model -> Html Msg
timerView model =
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
    div [ id "timer", class "tab" ]
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
                [ span [] [ text (timeLeft model.turn) ]
                , actionIcon <| actionOf model
                ]
            ]
        , audio [ src <| "/sound/" ++ model.audio.sound ] []
        ]


turnToString : Turn -> String
turnToString turn =
    case turn of
        On _ ->
            "on"

        Off ->
            "off"


timeLeft : Turn -> String
timeLeft turn =
    case turn of
        On t ->
            String.fromFloat t.timeLeft ++ "s"

        Off ->
            ""


actionOf : Model -> Action
actionOf model =
    case ( model.turn, model.audio.state ) of
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
            Ratio.from (1 - (turn.timeLeft - 1) / turn.turnLength)

        Off ->
            Ratio.full


mobbersView : Model -> Html msg
mobbersView model =
    div [ id "mobbers", class "tab" ]
        [ div
            [ id "add" ]
            [ input [ type_ "text", placeholder "Mobber name" ] []
            , button [] [ i [ class "fas fa-plus" ] [] ]
            ]
        , ul
            []
            [ li []
                [ i [ class "fas fa-bars" ] []
                , div
                    []
                    [ p [] [ text "Navigator" ]
                    , input [ type_ "text", value "John" ] []
                    ]
                ]
            , li []
                [ i [ class "fas fa-bars" ] []
                , div
                    []
                    [ p [] [ text "Navigator" ]
                    , input [ type_ "text", value "Jane" ] []
                    ]
                ]
            ]
        ]


settingsView : Model -> Html msg
settingsView model =
    div [ id "settings", class "tab" ]
        [ div []
            [ h2 []
                [ i [ class "fas fa-share-alt" ] []
                , text " Shared with the mob"
                ]
            , form
                []
                [ label [ for "length" ] [ text "Turn length (min)" ]
                , input [ id "length", type_ "number", Html.Attributes.min "1", Html.Attributes.max "99", value "4" ] []
                , label [ for "turns" ] [ text "Number of turns before break" ]
                , input [ id "turns", type_ "number", Html.Attributes.min "1", Html.Attributes.max "9", value "6" ] []
                , label [ for "roles" ] [ text "Roles" ]
                , input [ id "roles", type_ "text", value "Driver, Mavigator" ] []
                , label [ for "theme" ] [ text "Sounds" ]
                , select
                    []
                    [ option [] [ text "Classic" ] ]
                ]
            ]
        , div []
            [ h2 []
                [ i [ class "fas fa-user-lock" ] []
                , text " Private"
                ]
            , form
                []
                [ label [ for "volume" ] [ text "Volume" ]
                , input
                    [ id "length", type_ "range", Html.Attributes.min "0", Html.Attributes.max "100", value "60" ]
                    []
                ]
            ]
        ]
