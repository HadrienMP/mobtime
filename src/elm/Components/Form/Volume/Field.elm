module Components.Form.Volume.Field exposing (Msg(..), change, update, view)

import Components.Form.Volume.Type exposing (Volume, open)
import Components.Form.Volume.View as View
import Css
import Html.Styled exposing (Html)
import Lib.Alarm



-- Ports


change : Volume -> Cmd msg
change =
    open >> Lib.Alarm.alarmChangeVolume



-- Update


type Msg
    = Change Volume
    | Test


update : Msg -> Volume -> ( Volume, Cmd msg )
update msg volume =
    case msg of
        Change it ->
            ( it, Lib.Alarm.alarmChangeVolume <| open it )

        Test ->
            ( volume, Lib.Alarm.alarmTestVolume () )



-- View


view : Volume -> { labelWidth : Css.Style } -> Html Msg
view volume _ =
    View.display { onChange = Change, onTest = Test, volume = volume }
