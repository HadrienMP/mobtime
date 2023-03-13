module Components.Playlist.Doc exposing (doc)

import Components.Playlist.View
import ElmBook.Chapter exposing (chapter, renderComponent)
import ElmBook.ElmCSS exposing (Chapter)
import Sounds


doc : Chapter x
doc =
    chapter "Playlist"
        |> renderComponent (Components.Playlist.View.view Sounds.ClassicWeird)
