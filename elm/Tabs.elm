module Tabs exposing (..)

import Html exposing (Html, a, i, nav)
import Html.Attributes exposing (class, classList, href)
import Url


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


navView : Url.Url -> Html msg
navView current =
    nav []
        (List.map
            (\page ->
                a
                    [ href page.url, classList [ activeClass current page.url ] ]
                    [ i [ class <| "fas " ++ page.icon ] [] ]
            )
            tabs
        )


activeClass : Url.Url -> String -> ( String, Bool )
activeClass current tabUrl =
    ( "active", current.path == tabUrl )
