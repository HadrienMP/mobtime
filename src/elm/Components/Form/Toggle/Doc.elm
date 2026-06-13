module Components.Form.Toggle.Doc exposing (doc)

import Components.Form.Toggle.View
import ElmBook.Actions exposing (logAction)
import ElmBook.Chapter exposing (chapter, render, withComponent)
import ElmBook.ElmCSS exposing (Chapter)


doc : Chapter x
doc =
    chapter "Toggle"
        |> withComponent
            (Components.Form.Toggle.View.view
                { onToggle = logAction "Toggled"
                , value = True
                , labelOn = Just "On"
                , labelOff = Just "Off"
                , id = "toggle"
                }
            )
        |> render """
<component />

```elm
type Msg 
    = Toggled
    | ...

Components.Form.Toggle.View.view
    { onToggle = Toggled
    , value = True
    , labelOn = Just "On"
    , labelOff = Just "Off"
    }
```
"""
