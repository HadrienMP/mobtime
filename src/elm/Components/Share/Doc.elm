module Components.Share.Doc exposing (..)

import Components.Share.Button
import Components.Share.Modal
import ElmBook.Actions exposing (logAction, logActionWithString)
import ElmBook.Chapter exposing (chapter, renderComponentList)
import ElmBook.ElmCSS exposing (Chapter)
import UI.Palettes


theChapter : Chapter x
theChapter =
    chapter "Share"
        |> renderComponentList
            [ ( "Button"
              , Components.Share.Button.view
                    { onClick = logAction "Open Modal"
                    , color = UI.Palettes.monochrome.on.background
                    }
              )
            , ( "Modal"
              , Components.Share.Modal.view
                    { url = "https://mobtime.hadrienmp.fr/mob/my-fabulous-mob-yeah"
                    , copy = logActionWithString "Copied"
                    }
              )
            ]
