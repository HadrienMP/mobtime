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
            { mob = MobName "Awesome"
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
            , ( "With a name too long"
              , Components.NavBar.View.view
                    { props
                        | mob = MobName "That is a long name indeed, too long for the nav bar at least"
                    }
              )
            , ( "With letter going down"
              , Components.NavBar.View.view
                    { props
                        | mob = MobName "qpg"
                    }
              )
            ]
