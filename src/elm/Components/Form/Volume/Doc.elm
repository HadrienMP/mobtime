module Components.Form.Volume.Doc exposing (SharedState, State, doc, initState)

import Components.Form.Volume.Type as Type
import Components.Form.Volume.View as View
import ElmBook.Actions exposing (logAction, updateStateWith)
import ElmBook.Chapter exposing (chapter, render, withStatefulComponent)
import ElmBook.ElmCSS exposing (Chapter)


type alias State =
    Type.Volume


type alias SharedState x =
    { x | volume : Type.Volume }


initState : Type.Volume
initState =
    Type.Volume 25


updateSharedState : Type.Volume -> SharedState x -> SharedState x
updateSharedState volume x =
    { x | volume = volume }


doc : Chapter (SharedState x)
doc =
    chapter "Volume"
        |> withStatefulComponent component
        |> render content


component state =
    View.display
        { onChange = updateStateWith updateSharedState
        , onTest = logAction <| "Tested Sound, volume at " ++ (state.volume |> Type.open |> String.fromInt)
        , volume = state.volume
        }


content : String
content =
    """
<component />
```elm
Components.Form.Volume.View.display 
    { onChange = ChangeVolume
    , onTest = TestVolume
    , volume = Volume 25
    }
```
"""
