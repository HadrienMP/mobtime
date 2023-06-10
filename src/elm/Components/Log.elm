module Components.Log exposing (doc)

import ElmBook.Actions exposing (logAction)
import ElmBook.Chapter as Chapter
import ElmBook.ElmCSS exposing (Chapter)
import UI.Button.RoundIcon
import UI.Icons.Ion
import UI.Palettes as Palettes


doc : Chapter x
doc =
    Chapter.chapter "Log"
        |> Chapter.withComponent
            (UI.Button.RoundIcon.view []
                { target = UI.Button.RoundIcon.Button <| logAction "Clicked"
                , text = "Logs"
                , icon = UI.Icons.Ion.bug
                , color = Palettes.monochrome.on.background
                }
            )
        |> Chapter.render """
<component />
"""
