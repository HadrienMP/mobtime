module Components.Mobbers.Component exposing (Msg(..), update, view)

import Components.Mobbers.View
import Effect exposing (Effect)
import Html.Styled exposing (Html)
import Model.Events
import Model.Mob exposing (Mob)
import Model.Mobber exposing (MobberId)
import Model.Mobbers
import Pages.Mob.Routing
import Random
import Routing
import Shared exposing (Shared)


type Msg
    = Rotate
    | Shuffe
    | ChangedOrder Model.Mobbers.Mobbers
    | GoToSettings
    | Toggled MobberId


update : Shared -> Mob -> Msg -> Effect Shared.Msg Msg
update shared mob msg =
    case msg of
        Shuffe ->
            Effect.fromCmd <|
                Random.generate ChangedOrder <|
                    Model.Mobbers.shuffle mob.mobbers

        ChangedOrder mobbers ->
            Effect.share <| Model.Events.MobEvent mob.name <| Model.Events.ChangedMobbersOrder mobbers

        Rotate ->
            Effect.share <| Model.Events.MobEvent mob.name <| Model.Events.RotatedMobbers

        GoToSettings ->
            Shared.pushUrl shared <|
                Routing.Mob
                    { mob = mob.name
                    , subRoute = Pages.Mob.Routing.Mobbers
                    }

        Toggled id ->
            Effect.share <| Model.Events.MobEvent mob.name <| Model.Events.ToggledMobber id


view : Mob -> Html Msg
view state =
    Components.Mobbers.View.view
        { people = state.mobbers
        , roles = state.roles
        , onShuffle = Shuffe
        , onRotate = Rotate
        , onSettings = GoToSettings
        , onAdd = GoToSettings
        , onOrderChange = ChangedOrder
        , onToggle = Toggled
        }
