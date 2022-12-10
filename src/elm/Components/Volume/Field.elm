port module Components.Volume.Field exposing (..)

import Components.Volume.Type as Type exposing (Volume, open)
import Components.Volume.View as View
import Css
import Html.Styled exposing (Html)



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


view : Type.Volume -> { labelWidth : Css.Style } -> Html Msg
view volume _ =
    View.display { onChange = Change, onTest = Test, volume = volume }
