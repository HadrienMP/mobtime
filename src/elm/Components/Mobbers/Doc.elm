module Components.Mobbers.Doc exposing (doc)

import Components.Mobbers.View
import ElmBook.Chapter exposing (chapter, render, withComponentList)
import ElmBook.ElmCSS exposing (Chapter)
import Model.Role as Role


doc : Chapter x
doc =
    chapter "Mobbers"
        |> withComponentList
            [ ( "Defaults"
              , Components.Mobbers.View.view
                    { people = [ "Pin", "Manon", "Thomas", "Pauline", "Jeff", "Amélie" ]
                    , roles = [ "Driver", "Navigator" ] |> List.map Role.fromString
                    }
              )
            , ( "Inversed defaults"
              , Components.Mobbers.View.view
                    { people = [ "Pin", "Manon", "Thomas", "Pauline", "Jeff", "Amélie" ]
                    , roles = [ "Navigator", "Driver" ] |> List.map Role.fromString
                    }
              )
            , ( "Too many specials"
              , Components.Mobbers.View.view
                    { people = [ "Pin", "Manon", "Thomas", "Pauline", "Jeff", "Amélie" ]
                    , roles = [ "Navigator", "Driver", "Navigator", "Driver", "Navigator", "Driver" ] |> List.map Role.fromString
                    }
              )
            , ( "No specials"
              , Components.Mobbers.View.view
                    { people = [ "Pin", "Manon", "Thomas", "Pauline", "Jeff", "Amélie" ]
                    , roles = []
                    }
              )
            , ( "Custom"
              , Components.Mobbers.View.view
                    { people =
                        [ "Pin"
                        , "Manon"
                        , "Thomas"
                        , "Pauline"
                        , "Jeff"
                        , "Amélie"
                        ]
                    , roles = [ "Scribe", "Moderator", "Artist" ] |> List.map Role.fromString
                    }
              )
            , ( "Too Many real mobbers"
              , Components.Mobbers.View.view
                    { people =
                        [ "Pin"
                        , "Manon"
                        , "Thomas"
                        , "Pauline"
                        , "Jeff"
                        , "Amélie"
                        , "Pin"
                        , "Manon"
                        , "Thomas"
                        , "Pauline"
                        , "Jeff"
                        , "Amélie"
                        , "Pin"
                        , "Manon"
                        , "Thomas"
                        , "Pauline"
                        , "Jeff"
                        , "Amélie"
                        ]
                    , roles = []
                    }
              )
            ]
        |> render """
<component with-label="Defaults"/>
<component with-label="Inversed defaults"/>
<component with-label="Custom"/>

## Special cases
<component with-label="Too many specials"/>
<component with-label="No specials"/>
<component with-label="Too Many real mobbers"/>
"""
