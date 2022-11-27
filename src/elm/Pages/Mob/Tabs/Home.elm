module Pages.Mob.Tabs.Home exposing (..)

import Html.Styled exposing (Html, div, li, span, text, ul)
import Html.Styled.Attributes exposing (class, id)
import Js.Commands
import Model.MobName exposing (MobName)
import Model.Mobber exposing (Mobber)
import Model.Role exposing (Role)
import Model.State exposing (State)
import Pages.Mob.Tabs.Share
import Routing


type Msg
    = PutLinkInPasteBin String


update : Msg -> Cmd Msg
update msg =
    case msg of
        PutLinkInPasteBin url ->
            url
                |> Js.Commands.CopyInPasteBin
                |> Js.Commands.send


view : MobName -> State -> Html Msg
view mobName state =
    div
        [ id "home", class "tab" ]
        [ Pages.Mob.Tabs.Share.shareButton mobName <|
            PutLinkInPasteBin <|
                Routing.toUrl <|
                    Routing.Mob mobName
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
