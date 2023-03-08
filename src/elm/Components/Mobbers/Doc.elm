module Components.Mobbers.Doc exposing (doc)

import Components.Mobbers.View
import ElmBook.Chapter exposing (chapter, render, withComponent)
import ElmBook.ElmCSS exposing (Chapter)


doc : Chapter x
doc =
    chapter "Mobbers"
        |> withComponent
            (Components.Mobbers.View.view
                { people = [ "Pin", "Manon", "Thomas", "Pauline", "Jeff", "Amélie" ], roles = [ "Driver", "Navigator", "Next Up" ] }
            )
        |> render """
<component />
"""
