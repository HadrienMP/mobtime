module Pages.Mob.Tabs.Dev exposing (..)

import Dict
import Html.Styled exposing (Html, dd, div, dl, dt, p, text)
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
        [ toto model
        ]


toto : Peers.Sync.Adapter.Model -> Html Msg
toto model =
    case model of
        Peers.Sync.Adapter.Starting _ ->
            div [] [ text "Starting..." ]

        Peers.Sync.Adapter.Started record ->
            div []
                [ p [] [ text ("Me " ++ record.model.context.peerId) ]
                , dl []
                    (record.model.adjustments
                        |> Dict.toList
                        |> List.map (\( key, value ) -> [ dd [] [ text key ], dt [] [ tata value ] ])
                        |> List.foldr List.append []
                    )
                ]


tata : TimeAdjustment -> Html Msg
tata timeAdjustment =
    case timeAdjustment of
        RequestedAt posix ->
            div [] [ text "Requested" ]

        Fixed duration ->
            div [] [ print_delta duration |> text ]

print_delta : Duration -> String
print_delta duration =
    Duration.toMillis duration
    |> toFloat
    |> (\ms -> ms / 1000)
    |> String.fromFloat
    |> (\a -> a ++ " s")