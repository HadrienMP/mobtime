module Components.Socket.Doc exposing (theChapter)

import Components.Socket.View
import ElmBook.Chapter exposing (chapter, renderComponentList)
import ElmBook.ElmCSS exposing (Chapter)
import UI.Palettes


theChapter : Chapter x
theChapter =
    chapter "Socket"
        |> renderComponentList
            [ ( "Connected"
              , Components.Socket.View.view []
                    { socketConnected = True
                    , color = UI.Palettes.monochrome.on.background
                    }
              )
            , ( "Disconnected"
              , Components.Socket.View.view []
                    { socketConnected = False
                    , color = UI.Palettes.monochrome.on.background
                    }
              )
            ]
