module Components.Mobbers.Component exposing (Msg(..), update, view)

import Components.Mobbers.View
import Effect exposing (Effect)
import Html.Styled exposing (Html)
import Model.Events
import Model.Mob exposing (Mob)
import Model.Mobbers
import Pages.Mob.Routing
import Random
import Routing
import Shared exposing (Shared)


type Msg
    = Rotate
    | Shuffe
    | Shuffled Model.Mobbers.Mobbers
    | GoToSettings


update : Shared -> Mob -> Msg -> Effect Shared.Msg Msg
update shared mob msg =
    case msg of
        Shuffe ->
            Effect.fromCmd <|
                Random.generate Shuffled <|
                    Model.Mobbers.shuffle mob.mobbers

        Shuffled mobbers ->
            Effect.share <| Model.Events.MobEvent mob.name <| Model.Events.ShuffledMobbers mobbers

        Rotate ->
            Effect.share <| Model.Events.MobEvent mob.name <| Model.Events.RotatedMobbers

        GoToSettings ->
            -- TODO rename the name field to mob (routing)
            Shared.pushUrl shared <|
                Routing.Mob
                    { name = mob.name
                    , subRoute = Pages.Mob.Routing.Mobbers
                    }


view : Mob -> Html Msg
view state =
    Components.Mobbers.View.view
        { people = state.mobbers |> Model.Mobbers.toList
        , roles = state.roles.special
        , onShuffle = Shuffe
        , onRotate = Rotate
        , onSettings = GoToSettings
        }
