module Volume.Doc exposing (..)

import ElmBook.Actions exposing (logAction, updateStateWith)
import ElmBook.Chapter exposing (chapter, render, withStatefulComponent)
import ElmBook.ElmCSS exposing (Chapter)
import Volume.Component
import Volume.Type


type alias State =
    Volume.Type.Volume


type alias SharedState x =
    { x | volume : Volume.Type.Volume }


initState : Volume.Type.Volume
initState =
    Volume.Type.Volume 25


updateSharedState : Volume.Type.Volume -> SharedState x -> SharedState x
updateSharedState volume x =
    { x | volume = volume }


volumeChapter : Chapter (SharedState x)
volumeChapter =
    chapter "Volume field"
        |> withStatefulComponent component
        |> render content


component state =
    Volume.Component.display
        { onChange = updateStateWith updateSharedState
        , onTest = logAction <| "Tested Sound, volume at " ++ (state.volume |> Volume.Type.open |> String.fromInt)
        , volume = state.volume
        }


content : String
content =
    """
<component />
"""
