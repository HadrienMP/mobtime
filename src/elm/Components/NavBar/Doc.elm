module Components.NavBar.Doc exposing (..)

import Components.NavBar.View
import Components.Socket.View
import ElmBook.Chapter exposing (chapter, renderComponentList)
import ElmBook.ElmCSS exposing (Chapter)
import Model.MobName exposing (MobName(..))
import UI.Palettes


theChapter : Chapter x
theChapter =
    let
        props =
            { mob = Just <| MobName "Awesome"
            , socket =
                Components.Socket.View.view []
                    { socketConnected = False
                    , color = UI.Palettes.monochrome.on.surface
                    }
            , addedStyle = []
            }
    in
    chapter "Nav bar"
        |> renderComponentList
            [ ( "Default", Components.NavBar.View.view props )
            , ( "With a name too long", Components.NavBar.View.view { props | mob = Just <| MobName "Awesome" } )
            , ( "With a mob", Components.NavBar.View.view { props | mob = Nothing } )
            ]
