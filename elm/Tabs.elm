module Tabs exposing (..)

import Html exposing (Html, a, i, nav)
import Html.Attributes exposing (class, classList)
import Html.Events exposing (onClick)
import Url

type Msg
    = Clicked Tab

type TabType
    = Timer
    | Mobbers
    | SoundTab
    | DevTab


type alias Tab =
    { type_ : TabType
    , url : String
    , name : String
    , icon : String
    }


timerTab : Tab
timerTab =
    Tab Timer "/timer" "Timer" "fa-clock"


tabs : List Tab
tabs =
    [ timerTab
    , Tab Mobbers "/mobbers" "Mobbers" "fa-users"
    , Tab SoundTab "/audio" "Sound" "fa-volume-up"
    , Tab DevTab "/dev" "Dev" "fa-code"
    ]


tabFrom : Url.Url -> Tab
tabFrom url =
    tabs
        |> List.filter (\p -> p.url == url.path)
        |> List.head
        |> Maybe.withDefault timerTab


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
