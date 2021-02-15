module Tabs.Tabs exposing (..)

import Html exposing (Html, a, i, nav)
import Html.Attributes exposing (class, classList)
import Html.Events exposing (onClick)

type Msg
    = Clicked Tab

type TabType
    = Timer
    | Mobbers
    | Sound
    | Dev
    | Share


type alias Tab =
    { type_ : TabType
    , icon : String
    }


timerTab : Tab
timerTab =
    Tab Timer "fa-clock"


tabs : List Tab
tabs =
    [ timerTab
    , Tab Mobbers "fa-users"
    , Tab Sound "fa-volume-up"
    , Tab Share "fa-share-alt"
    , Tab Dev "fa-code"
    ]


navView : Tab -> Html Msg
navView current =
    nav []
        (List.map
            (\tab ->
                a
                    [ onClick <| Clicked tab, classList [ activeClass current tab ] ]
                    [ i [ class <| "fas " ++ tab.icon ] [] ]
            )
            tabs
        )


activeClass : Tab -> Tab -> ( String, Bool )
activeClass current tab =
    ( "active", current == tab )
