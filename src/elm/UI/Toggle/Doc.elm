module UI.Toggle.Doc exposing (theChapter)

import ElmBook.Actions exposing (logAction)
import ElmBook.Chapter exposing (chapter, render, withComponentList)
import ElmBook.ElmCSS exposing (Chapter)
import UI.Toggle.View


theChapter : Chapter x
theChapter =
    let
        props =
            { onToggle = logAction "Toggle switched"
            , value = True
            }
    in
    chapter "Toggle"
        |> withComponentList
            [ ( "Active", UI.Toggle.View.view props )
            , ( "Inactive", UI.Toggle.View.view { props | value = False } )
            ]
        |> render """
```elm
type Msg
  = Toggled
  | ...

UI.Toggle.View.view 
  { onToggle = Toggled 
  , value = True
  }
```
<component with-label="Active" />
<component with-label="Inactive" />
"""
