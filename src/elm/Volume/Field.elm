port module Volume.Field exposing (..)

import Css
import Html.Styled exposing (Html)
import Volume.Component
import Volume.Type exposing (Volume, open)



-- Ports


change : Volume -> Cmd msg
change =
    open >> changeVolume


port changeVolume : Int -> Cmd msg


port testVolume : () -> Cmd msg



-- Update


type Msg
    = Change Volume
    | Test


update : Msg -> Volume -> ( Volume, Cmd msg )
update msg volume =
    case msg of
        Change it ->
            ( it, changeVolume <| open it )

        Test ->
            ( volume, testVolume () )



-- View


view : Volume.Type.Volume -> { labelWidth : Css.Style } -> Html Msg
view volume _ =
    Volume.Component.display { onChange = Change, onTest = Test, volume = volume }
