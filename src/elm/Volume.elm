module Volume exposing (..)

import Volume.Field
import Volume.Type


type alias Volume =
    Volume.Type.Volume


type alias Msg =
    Volume.Field.Msg


default =
    Volume.Type.default


change =
    Volume.Field.change


encode =
    Volume.Type.encode


decoder =
    Volume.Type.decoder


update =
    Volume.Field.update


view =
    Volume.Field.view
