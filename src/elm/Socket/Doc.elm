module Socket.Doc exposing (..)

import ElmBook.Chapter exposing (chapter, renderComponentList)
import ElmBook.ElmCSS exposing (Chapter)
import Socket.Component
import UI.Palettes


theChapter : Chapter x
theChapter =
    chapter "Socket"
        |> renderComponentList
            [ ( "Connected"
              , Socket.Component.display []
                    { socketConnected = True
                    , color = UI.Palettes.monochrome.on.background
                    }
              )
            , ( "Disconnected"
              , Socket.Component.display []
                    { socketConnected = False
                    , color = UI.Palettes.monochrome.on.background
                    }
              )
            ]
