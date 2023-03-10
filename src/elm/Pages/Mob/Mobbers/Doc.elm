module Pages.Mob.Mobbers.Doc exposing (SharedState, doc, initState)

import ElmBook.Actions exposing (logAction, logActionWith, updateStateWith)
import ElmBook.Chapter exposing (chapter, renderStatefulComponent)
import ElmBook.ElmCSS exposing (Chapter)
import Model.MobName exposing (MobName(..))
import Model.Mobber
import Model.Role
import Pages.Mob.Mobbers.PageView


type alias SharedState x =
    { x | mobberPageName : String }


initState : String
initState =
    ""


updateSharedState : String -> SharedState x -> SharedState x
updateSharedState value x =
    { x | mobberPageName = value }


doc : Chapter (SharedState x)
doc =
    chapter "Mobbers"
        |> renderStatefulComponent
            (\state ->
                Pages.Mob.Mobbers.PageView.view
                    { people = [ "Pin", "Manon", "Thomas", "Pauline", "Jeff", "Amélie" ] |> toMobbers
                    , roles = [ "Driver", "Navigator" ] |> List.map Model.Role.fromString
                    , onShuffle = logAction "Shuffled"
                    , onRotate = logAction "Rotated"
                    , onDelete = logActionWith .name "Deleted"
                    , onBack = logAction "Back"
                    , mob = MobName "Awesome"
                    , input =
                        { value = state.mobberPageName
                        , onChange = updateStateWith updateSharedState
                        , onSubmit = logAction "Add mobber"
                        }
                    }
            )


toMobbers : List String -> List Model.Mobber.Mobber
toMobbers =
    List.indexedMap Tuple.pair
        >> List.map
            (\( i, n ) ->
                { id = Model.Mobber.idFromString <| String.fromInt i
                , name = n
                }
            )
