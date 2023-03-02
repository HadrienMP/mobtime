module Components.Form.Toggle.Doc exposing (..)

import Components.Form.Toggle.View
import ElmBook.Actions exposing (logAction)
import ElmBook.Chapter exposing (chapter, render, withComponent)
import ElmBook.ElmCSS exposing (Chapter)


doc : Chapter x
doc =
    chapter "Toggle"
        |> withComponent
            (Components.Form.Toggle.View.view
                { id = "id"
                , onToggle = logAction "Toggled"
                , value = True
                , label = "My Toggle"
                , labelOn = Just "On"
                , labelOff = Just "Off"
                }
            )
        |> render """
<component />

```elm
type Msg 
    = Toggled
    | ...

Components.Form.Toggle.View.view
    { id = "id"
    , onToggle = Toggled
    , value = True
    , label = "My Toggle"
    , labelOn = Just "On"
    , labelOff = Just "Off"
    }
```
"""
