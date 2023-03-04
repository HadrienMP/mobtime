module Pages.Mob.Tabs.Home exposing (Msg(..), update, view)

import Html.Styled exposing (Html, div, li, span, text, ul)
import Html.Styled.Attributes exposing (class, id)
import Model.MobName exposing (MobName)
import Model.Mobber exposing (Mobber)
import Model.Role exposing (Role)
import Model.State exposing (State)
import Shared exposing (Shared)


type Msg
    = Noop


update : Msg -> Cmd Msg
update _ =
    Cmd.none


view : Shared -> MobName -> State -> Html Msg
view _ mob state =
    div
        [ id "home", class "tab" ]
        [ text <| "You are in the mob: " ++ Model.MobName.print mob
        , roles state
        ]


roles : State -> Html msg
roles state =
    Model.State.assignSpecialRoles state
        |> List.map roleView
        |> (\list ->
                case list of
                    [] ->
                        div [] []

                    _ ->
                        ul [ class "mobber-roles" ] list
           )


roleView : ( Role, Mobber ) -> Html msg
roleView ( role, mobber ) =
    li [ class "mobber-role" ]
        [ span [ class "role" ] [ role |> Model.Role.print |> text ]
        , span [ class "mobber" ] [ mobber.name |> text ]
        ]
