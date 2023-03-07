module UI.Link.Doc exposing (doc)

import ElmBook.Chapter exposing (chapter, render, withComponent)
import ElmBook.ElmCSS exposing (Chapter)
import UI.Icons.Ion
import UI.Link.IconLink
import UI.Palettes as Palettes


doc : Chapter x
doc =
    chapter "Link"
        |> withComponent
            (UI.Link.IconLink.view []
                { target = "#here"
                , text = "To somewhere"
                , icon = UI.Icons.Ion.code
                , color = Palettes.monochrome.on.background
                }
            )
        |> render """
## Icon Link
<component />

```elm
UI.Link.IconLink.view []
    { target = "#here"
    , text = "To somewhere"
    , icon = UI.Icons.Ion.code
    , color = UI.Palettes.monochrome.on.background
    }
```
"""
