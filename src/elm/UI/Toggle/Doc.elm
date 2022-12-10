module UI.Toggle.Doc exposing (..)

import ElmBook.Actions exposing (logActionWithBool)
import ElmBook.Chapter exposing (chapter, renderComponentList)
import ElmBook.ElmCSS exposing (Chapter)
import UI.Toggle.Component


theChapter : Chapter x
theChapter =
    let
        props =
            { onToggle = logActionWithBool "Toggle switched"
            , value = True
            }
    in
    chapter "Toggle"
        |> renderComponentList
            [ ( "Active", UI.Toggle.Component.display props )
            , ( "Inactive", UI.Toggle.Component.display { props | value = False } )
            ]
