module Mob.Tabs.Tabs exposing (..)

import Html exposing (Html, button, i, nav)
import Html.Attributes exposing (class, classList)
import Html.Events exposing (onClick)

type Msg
    = Clicked Tab

type TabType
    = Home
    | Timer
    | Mobbers
    | Sound
    | Share


type alias Tab =
    { type_ : TabType
    , icon : String
    }


default : Tab
default =
    Tab Home "fa-home"


tabs : List Tab
tabs =
    [ default
    , Tab Timer "fa-clock"
    , Tab Mobbers "fa-users"
    , Tab Sound "fa-volume-up"
    , Tab Share "fa-share-alt"
    ]


navView : Tab -> Html Msg
navView current =
    nav []
        (List.map
            (\tab ->
                button
                    [ onClick <| Clicked tab, classList [ activeClass current tab ]]
                    [ i [ class <| "fas " ++ tab.icon ] [] ]
            )
            tabs
        )


activeClass : Tab -> Tab -> ( String, Bool )
activeClass current tab =
    ( "active", current == tab )
