module Lib.DocumentExtras exposing (..)

import Browser
import Html


map : (a -> b) -> Browser.Document a -> Browser.Document b
map f document =
    { title = document.title, body = document.body |> (List.map <| Html.map f) }
