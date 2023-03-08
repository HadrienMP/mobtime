module Pages.Mob.Profile.Doc exposing (profileChapter)

import Components.Form.Volume.Type exposing (Volume(..))
import ElmBook.Actions exposing (logAction)
import ElmBook.Chapter exposing (chapter, renderComponentList)
import ElmBook.ElmCSS exposing (Chapter)
import Model.MobName exposing (MobName(..))
import Pages.Mob.Profile.View


profileChapter : Chapter x
profileChapter =
    chapter "Profile page"
        |> renderComponentList
            [ ( "With mob"
              , Pages.Mob.Profile.View.view
                    { mob = MobName "A Mob"
                    , onJoin = logAction "Join mob"
                    , volume =
                        { onChange = always <| logAction "Volume change"
                        , onTest = logAction "Test audio at level"
                        , volume = Volume 15
                        }
                    }
              )
            ]
