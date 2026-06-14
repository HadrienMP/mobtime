module Components.Socket.Doc exposing (theChapter)

import Components.Socket.View exposing (SocketStatus(..))
import ElmBook.Chapter exposing (chapter, renderComponentList)
import ElmBook.ElmCSS exposing (Chapter)
import UI.Palettes as Palettes


theChapter : Chapter x
theChapter =
    chapter "Socket"
        |> renderComponentList
            [ ( "Connected"
              , Components.Socket.View.view []
                    { status = Connected
                    , color = Palettes.monochrome.on.background
                    }
              )
            , ( "Disconnected"
              , Components.Socket.View.view []
                    { status = Disconnected
                    , color = Palettes.monochrome.on.background
                    }
              )
            ]
