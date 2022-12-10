module Pages.Profile.Doc exposing (..)

import ElmBook.Actions exposing (logAction, logActionWithBool)
import ElmBook.Chapter exposing (chapter, renderComponent)
import ElmBook.ElmCSS exposing (Chapter)
import Model.MobName exposing (MobName(..))
import Pages.Profile.Component
import Volume.Type exposing (Volume(..))


profileChapter : Chapter x
profileChapter =
    chapter "Profile page"
        |> renderComponent component


component =
    Pages.Profile.Component.display
        { mob = MobName "A mob"
        , secondsToggle =
            { onToggle = logActionWithBool "Display seconds"
            , value = True
            }
        , onJoin = logAction "Join mob"
        , volume =
            { onChange = always <| logAction "Volume change"
            , onTest = logAction "Test audio at level"
            , volume = Volume 15
            }
        }
