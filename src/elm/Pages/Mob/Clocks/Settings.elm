module Pages.Mob.Clocks.Settings exposing (..)

import Html exposing (Html, button, div, input, label, text)
import Html.Attributes exposing (class, classList, for, id, step, type_, value)
import Html.Events exposing (onClick, onInput)
import Js.Events
import Lib.Duration as Duration
import Lib.Icons.Animals
import Pages.Mob.Name exposing (MobName)
import Peers.Events


type alias Model =
    { displaySeconds : Bool }


init : Model
init =
    { displaySeconds = False }


type Msg
    = DisplaySecondsChanged Bool
    | ShareEvent Peers.Events.Event


update : Msg -> Model -> MobName -> ( Model, Cmd Msg )
update msg model mob =
    case msg of
        DisplaySecondsChanged bool ->
            ( { model | displaySeconds = bool }, Cmd.none )

        ShareEvent event ->
            ( model
            , event
                |> Peers.Events.MobEvent mob
                |> Peers.Events.mobEventToJson
                |> Peers.Events.sendEvent
            )


view : Duration.Duration -> Model -> Html Msg
view turnLength model =
    div [ id "timer", class "tab" ]
        [ div
            [ id "seconds-field", class "form-field" ]
            [ label [ for "seconds" ] [ text "Seconds" ]
            , div
                [ class "toggles" ]
                [ button
                    [ classList [ ( "active", not model.displaySeconds ) ]
                    , onClick <| DisplaySecondsChanged False
                    ]
                    [ text "Hide" ]
                , button
                    [ classList [ ( "active", model.displaySeconds ) ]
                    , onClick <| DisplaySecondsChanged True
                    ]
                    [ text "Show" ]
                ]
            ]
        , div
            [ id "turn-length-field", class "form-field" ]
            [ label
                [ for "turn-length" ]
                [ text <|
                    "Turn : "
                        ++ (String.fromInt <| Duration.toMinutes turnLength)
                        ++ " min"
                ]
            , div [ class "field-input" ]
                [ Lib.Icons.Animals.rabbit
                , input
                    [ id "turn-length"
                    , type_ "range"
                    , step "1"
                    , onInput <|
                        String.toInt
                            >> Maybe.withDefault 8
                            >> Duration.ofMinutes
                            >> Peers.Events.TurnLengthChanged
                            >> ShareEvent
                    , Html.Attributes.min "2"
                    , Html.Attributes.max "20"
                    , value <| String.fromInt <| Duration.toMinutes turnLength
                    ]
                    []
                , Lib.Icons.Animals.elephant
                ]
            ]
        ]
