module Pages.Profile.Doc exposing (..)

import Components.Volume.Type exposing (Volume(..))
import ElmBook.Actions exposing (logAction)
import ElmBook.Chapter exposing (chapter, renderComponentList)
import ElmBook.ElmCSS exposing (Chapter)
import Model.MobName exposing (MobName(..))
import Pages.Profile.View


profileChapter : Chapter x
profileChapter =
    chapter "Profile page"
        |> renderComponentList
            [ ( "With mob", component <| Just <| MobName "A Mob" )
            , ( "Without mob", component Nothing )
            ]


component mob =
    Pages.Profile.View.view
        { mob = mob
        , secondsToggle =
            { onToggle = logAction "Display seconds"
            , value = True
            }
        , onJoin = logAction "Join mob"
        , volume =
            { onChange = always <| logAction "Volume change"
            , onTest = logAction "Test audio at level"
            , volume = Volume 15
            }
        }
