module Components.Volume.Doc exposing (..)

import Components.Volume.Type as Type
import Components.Volume.View as View
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


theChapter : Chapter (SharedState x)
theChapter =
    chapter "Volume field"
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
type Volume = Volume Int

Components.Volume.View.display: 
    { onChange : Volume -> msg
    , onTest : msg
    , volume : Volume
    } -> Html msg
```
"""
