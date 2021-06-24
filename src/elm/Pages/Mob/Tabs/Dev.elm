module Pages.Mob.Tabs.Dev exposing (..)

import Dict
import Html.Styled exposing (Html, div, p, strong, table, td, text, th, tr)
import Html.Styled.Attributes exposing (class, id)
import Lib.Duration as Duration exposing (Duration(..))
import Peers.Sync.Adapter
import Peers.Sync.Core exposing (TimeAdjustment(..))



-- UPDATE


type Msg
    = None


update : Msg -> Cmd Msg
update msg =
    case msg of
        None ->
            Cmd.none



-- VIEW


view : Peers.Sync.Adapter.Model -> Html Msg
view model =
    div [ id "dev", class "tab" ]
        (case model of
            Peers.Sync.Adapter.Starting _ ->
                [ div [] [ text "Starting..." ] ]

            Peers.Sync.Adapter.Started started ->
                [ displayTimeAdjustments started ]
        )


displayTimeAdjustments started =
    div []
        [ p [] [ strong [] [text "Peer Id: "], text started.model.context.peerId ]
        , table []
            ([ tr []
                [ th [] [ text "Peer" ]
                , th [] [ text "Adjustment" ]
                ]
             ]
                ++ (started.model.adjustments
                        |> Dict.toList
                        |> List.map (\( key, value ) -> tr [] [ td [] [ text key ], td [] [ displayTimeAdjustment value ] ])
                   )
            )
        ]


displayTimeAdjustment : TimeAdjustment -> Html Msg
displayTimeAdjustment timeAdjustment =
    case timeAdjustment of
        RequestedAt _ ->
            div [] [ text "Requested" ]

        Fixed duration ->
            div [] [ durationToString duration |> text ]


durationToString : Duration -> String
durationToString duration =
    let
        m =
            Duration.toMinutes duration

        seconds_left =
            Duration.ofMinutes m
                |> Duration.subtract duration

        s =
            seconds_left
                |> Duration.toMillis
                |> toFloat
                |> abs
                |> (\ms -> ms / 1000)
    in
    String.fromInt m ++ ":" ++ String.fromFloat s
