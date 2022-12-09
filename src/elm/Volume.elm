port module Volume exposing (..)

import Css
import Effect exposing (Effect)
import Html.Styled as Html exposing (Html)
import Html.Styled.Attributes as Attr
import Html.Styled.Events as Evts
import Json.Decode as Decode
import Json.Encode as Json
import Shared
import UI.Buttons
import UI.Column
import UI.Icons.Ion
import UI.Palettes
import UI.Rem
import UI.Row



-- Ports


port changeVolume : Int -> Cmd msg


port testVolume : () -> Cmd msg



-- Type


type Volume
    = Volume Int


default : Volume
default =
    Volume 50


open : Volume -> Int
open (Volume raw) =
    raw



-- Json


encode : Volume -> Json.Value
encode =
    open >> Json.int


decoder : Decode.Decoder Volume
decoder =
    Decode.int |> Decode.map Volume



-- Update


type Msg
    = Change Volume
    | Test


update : Msg -> Volume -> ( Volume, Effect Shared.Msg Msg )
update msg volume =
    case msg of
        Change it ->
            ( it, Effect.fromCmd <| changeVolume <| open it )

        Test ->
            ( volume, Effect.fromCmd <| testVolume () )



-- View


view : Volume -> { labelWidth : Css.Style } -> Html Msg
view volume { labelWidth } =
    UI.Row.row
        [ Attr.css [ Css.width <| Css.pct 100 ] ]
        []
        [ Html.label
            [ Attr.for "volume", Attr.css [ labelWidth ] ]
            [ Html.text "Volume" ]
        , UI.Column.column [ Attr.css [ Css.flexGrow <| Css.int 1 ] ]
            [ UI.Column.Gap <| UI.Rem.Rem 0.4 ]
            [ UI.Row.row []
                []
                [ UI.Icons.Ion.volumeLow
                    { size = UI.Rem.Rem 1
                    , color = UI.Palettes.monochrome.on.background
                    }
                , Html.input
                    [ Attr.id "volume"
                    , Attr.type_ "range"
                    , Evts.onInput
                        (String.toInt
                            >> Maybe.map Volume
                            >> Maybe.withDefault volume
                            >> Change
                        )
                    , Attr.max "50"
                    , Attr.value <| String.fromInt <| open volume
                    ]
                    []
                , UI.Icons.Ion.volumeHigh
                    { size = UI.Rem.Rem 1
                    , color = UI.Palettes.monochrome.on.background
                    }
                ]
            , UI.Buttons.button []
                { content = UI.Buttons.Both { icon = UI.Icons.Ion.musicNote, text = "Test the audio" }
                , variant = UI.Buttons.Secondary
                , size = UI.Buttons.S
                , action = UI.Buttons.OnPress <| Just Test
                }
            ]
        ]
