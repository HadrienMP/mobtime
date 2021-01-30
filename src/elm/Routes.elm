module Routes exposing (..)

import Mob exposing (MobName)
import NEString
import Url.Parser exposing ((</>), Parser, oneOf)
type Route
  = Login
  | Timer MobName
  | Mobbers MobName

parser : Parser (Route -> a) a
parser =
  oneOf
    [ Url.Parser.map Login Url.Parser.top
    , Url.Parser.map Timer (Url.Parser.custom "MOB" NEString.from </> Url.Parser.s "timer")
    , Url.Parser.map Mobbers (Url.Parser.custom "MOB" NEString.from </> Url.Parser.s "mobbers")
    ]

mobbersUrl mob =
    (NEString.toString mob) ++ "/mobbers"
timerUrl mob =
    (NEString.toString mob) ++ "/timer"