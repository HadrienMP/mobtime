module Components.Form.Input.Doc exposing (SharedState, doc, initState)

import Components.Form.Input.View
import ElmBook.Actions exposing (updateStateWith)
import ElmBook.Chapter exposing (chapter, render, withStatefulComponent)
import ElmBook.ElmCSS exposing (Chapter)


type alias SharedState x =
    { x | input : String }


initState : String
initState =
    ""


updateSharedState : String -> SharedState x -> SharedState x
updateSharedState value x =
    { x | input = value }


doc : Chapter (SharedState x)
doc =
    chapter "Input"
        |> withStatefulComponent component
        |> render content


component state =
    Components.Form.Input.View.view
        { id = "myfield"
        , label = "Name"
        , value = state.input
        , onChange = updateStateWith updateSharedState
        }


content : String
content =
    """
<component />
```elm
type Msg
    = Changed String
    | ...

Components.Form.Input.View.view 
    { label = "Name"
    , value = "Jeff"
    , onChange = Changed
    }
```
"""
