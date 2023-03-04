module Pages.Mob.Tabs.Dev exposing (view)

import Html.Styled exposing (Html, h2, text)
import Html.Styled.Attributes exposing (class, id)



-- VIEW


view : Html msg
view =
    h2 [ id "dev", class "tab" ] [ text "Dev mode active" ]
