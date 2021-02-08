port module Main exposing (..)

import Browser
import Browser.Events
import Browser.Navigation as Nav
import Circle
import Html exposing (Html, a, audio, button, div, form, header, i, input, li, nav, p, section, span, text, ul)
import Html.Attributes exposing (class, classList, href, id, placeholder, src, type_, value)
import Html.Events exposing (onClick, onInput, onSubmit)
import Json.Decode as Decode
import Json.Encode
import Random
import Ratio exposing (Ratio)
import Sounds
import Svg exposing (Svg, svg)
import Svg.Attributes as Svg
import Tabs.Timer as Timer
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


port soundCommands : Json.Encode.Value -> Cmd msg


port soundEnded : (String -> msg) -> Sub msg



-- MODEL


type TabType
    = Timer
    | Mobbers


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
    , volume : Int
    }


type SoundStatus
    = Playing
    | NotPlaying


type alias Roles =
    List String


type alias Mobbers =
    List String


type alias MobberRole =
    { role : String
    , name : String
    }


type alias Model =
    { key : Nav.Key
    , url : Url.Url
    , tab : Tab
    , turnLength : Int
    , turn : Turn
    , displaySeconds : Bool
    , audio : Audio
    , roles : List String
    , newMobberName : String
    , mobbers : Mobbers
    }


type Turn
    = Off
    | On { timeLeft : Int, length : Int }


init : String -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init _ url key =
    ( { key = key
      , url = url
      , tab = pageFrom url |> Maybe.withDefault timerPage
      , turnLength = 8
      , displaySeconds = False
      , turn = Off
      , audio =
            { state = NotPlaying
            , sound = Sounds.default
            , volume = 50
            }
      , roles = [ "Driver", "Navigator" ]
      , newMobberName = ""
      , mobbers = []
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
    | NewMobberNameChanged String
    | AddMobber
    | DeleteMobber String
    | OnABreak String
    | TimerMsg Timer.Msg


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
                        ( { model | turn = Off, audio = (\audio -> { audio | state = Playing }) model.audio }
                        , soundCommands playCommand
                        )

                    else
                        ( { model | turn = On { turn | timeLeft = turn.timeLeft - 1 } }
                        , Cmd.none
                        )

                Off ->
                    ( model, Cmd.none )

        StartRequest ->
            ( { model | turn = On { timeLeft = model.turnLength * 60, length = model.turnLength } }
            , Random.generate PickedSound Sounds.pick
            )

        StopRequest ->
            ( { model | turn = Off }
            , Cmd.none
            )

        PickedSound sound ->
            ( { model | audio = (\audio -> { audio | state = NotPlaying, sound = sound }) model.audio }
            , Cmd.none
            )

        SoundEnded _ ->
            ( { model | audio = (\audio -> { audio | state = NotPlaying }) model.audio }
            , Cmd.none
            )

        StopSoundRequest ->
            ( { model | audio = (\audio -> { audio | state = NotPlaying }) model.audio }
            , soundCommands stopCommand
            )

        NewMobberNameChanged newMobberName ->
            ( { model | newMobberName = newMobberName }
            , Cmd.none
            )

        AddMobber ->
            ( { model | newMobberName = "", mobbers = model.mobbers ++ [ model.newMobberName ] }
            , Cmd.none
            )

        DeleteMobber mobber ->
            ( { model | mobbers = List.filter (\m -> m /= mobber) model.mobbers }
            , Cmd.none
            )

        OnABreak _ ->
            ( model
            , Cmd.none
            )

        TimerMsg timerMsg ->
            case timerMsg of
                Timer.VolumeChanged volume ->
                    ( { model | audio = (\audio -> { audio | volume = String.toInt volume |> Maybe.withDefault audio.volume }) model.audio }
                    , soundCommands <| changeVolume volume
                    )

                Timer.TurnLengthChanged turnLength ->
                    ( { model | turnLength = String.toInt turnLength |> Maybe.withDefault 8 }
                    , Cmd.none
                    )

                Timer.DisplaySecondsChanged displaySeconds ->
                    ( { model | displaySeconds = displaySeconds }
                    , Cmd.none
                    )



playCommand : Json.Encode.Value
playCommand =
    Json.Encode.object
        [ ( "name", Json.Encode.string "play" )
        , ( "data", Json.Encode.object [] )
        ]


stopCommand : Json.Encode.Value
stopCommand =
    Json.Encode.object
        [ ( "name", Json.Encode.string "stop" )
        , ( "data", Json.Encode.object [] )
        ]


changeVolume : String -> Json.Encode.Value
changeVolume volume =
    Json.Encode.object
        [ ( "name", Json.Encode.string "volume" )
        , ( "data"
          , Json.Encode.object
                [ ( "volume", Json.Encode.string volume ) ]
          )
        ]



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
            [ headerView model
            , case model.tab.type_ of
                Timer ->
                    Timer.view model.displaySeconds model.turnLength model.audio.volume |> Html.map TimerMsg

                Mobbers ->
                    mobbersView model
            ]
        ]
    }



-- ############################################################
-- HEADER
-- ############################################################


headerView : Model -> Html Msg
headerView model =
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
                [ span [] [ text <| timeLeft model ]
                , actionIcon <| actionOf model
                ]
            ]
        , audio [ src <| "/sound/" ++ model.audio.sound ] []
        , nav [] <| navLinks model.url
        ]


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


turnToString : Turn -> String
turnToString turn =
    case turn of
        On _ ->
            "on"

        Off ->
            "off"


timeLeft : Model -> String
timeLeft model =
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
                        (String.fromInt intMinutes) ++ " min "

                    else
                        ""

                secondsText =
                    if secondsLeft /= 0 then
                        String.fromInt secondsLeft ++ " s"

                    else
                        ""
            in
            if model.displaySeconds || t.timeLeft < 60 then
                minutesText ++ secondsText

            else
                (String.fromInt <| ceiling floatMinutes) ++ " min"

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
            (1 - (toFloat (turn.timeLeft - 1) / (toFloat turn.length * 60)))
                |> Debug.log ""
                |> Ratio.from

        Off ->
            Ratio.full



-- ############################################################
-- MOBBERS
-- ############################################################


mobbersView : Model -> Html Msg
mobbersView model =
    div [ id "mobbers", class "tab" ]
        [ form
            [ id "add", onSubmit AddMobber ]
            [ input [ type_ "text", placeholder "Mobber name", onInput NewMobberNameChanged, value model.newMobberName ] []
            , button [ type_ "submit" ] [ i [ class "fas fa-plus" ] [] ]
            ]
        , ul
            []
            (assignRoles model.mobbers model.roles
                |> List.map
                    (\mobber ->
                        li []
                            [ p [] [ text mobber.role ]
                            , div
                                []
                                [ input [ type_ "text", value <| capitalize mobber.name ] []
                                , button [ onClick <| OnABreak mobber.name ] [ i [ class "fas fa-mug-hot" ] [] ]
                                , button [ onClick <| DeleteMobber mobber.name ] [ i [ class "fas fa-times" ] [] ]
                                ]
                            ]
                    )
            )
        ]


capitalize : String -> String
capitalize string =
    (String.left 1 string |> String.toUpper)
        ++ (String.dropLeft 1 string |> String.toLower)


assignRoles : Mobbers -> Roles -> List MobberRole
assignRoles mobbers roles =
    List.indexedMap Tuple.pair mobbers
        |> List.map (\( i, name ) -> { role = getRole i roles, name = name })


getRole : Int -> Roles -> String
getRole index roles =
    List.indexedMap Tuple.pair roles
        |> List.filter (\( i, _ ) -> i == index)
        |> List.map Tuple.second
        |> List.head
        |> Maybe.withDefault "Mobber"
