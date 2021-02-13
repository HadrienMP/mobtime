module Settings.TimerSettings exposing (..)

import Html exposing (Html, a, div, hr, i, input, label, strong, text)
import Html.Attributes exposing (checked, class, for, id, step, type_, value)
import Html.Events exposing (onCheck, onInput)
import Lib.Duration as Duration exposing (Duration)


type alias Model =
    { turnLength : Duration
    , displaySeconds : Bool
    }


init : Model
init =
    { turnLength = Duration.ofMinutes 8
    , displaySeconds = False
    }


type Msg
    = TurnLengthChanged String
    | DisplaySecondsChanged Bool


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        TurnLengthChanged turnLength ->
            ( { model | turnLength = String.toInt turnLength |> Maybe.withDefault 8 |> Duration.ofMinutes }
            , Cmd.none
            )

        DisplaySecondsChanged displaySeconds ->
            ( { model | displaySeconds = displaySeconds }
            , Cmd.none
            )


format : Model -> Duration -> List String
format model duration =
    if model.displaySeconds then
        Duration.toLongString duration

    else
        Duration.toShortString duration


view : Model -> Html Msg
view model =
    div [ id "timer", class "tab" ]
        [ a [ id "share-link" ]
            [ text "You are in the "
            , strong [] [ text "Agicap" ]
            , text " mob"
            , i [ id "share-button", class "fas fa-share-alt" ] []
            ]
        , hr [] []
        , div
            [ id "seconds-field", class "form-field" ]
            [ label [ for "seconds" ] [ text "Display seconds" ]
            , input
                [ id "seconds"
                , type_ "checkbox"
                , onCheck DisplaySecondsChanged
                , checked model.displaySeconds
                ]
                []
            ]
        , div
            [ id "turn-length-field", class "form-field" ]
            [ label
                [ for "turn-length" ]
                [ text <|
                    "Turn : "
                        ++ (String.fromInt <| Duration.toMinutes model.turnLength)
                        ++ " min"
                ]
            , i [ class "fas fa-dove" ] []
            , input
                [ id "turn-length"
                , type_ "range"
                , step "1"
                , onInput TurnLengthChanged
                , Html.Attributes.min "2"
                , Html.Attributes.max "20"
                , value <| String.fromInt <| Duration.toMinutes model.turnLength
                ]
                []
            , i [ class "fas fa-hippo" ] []
            ]
        ]
