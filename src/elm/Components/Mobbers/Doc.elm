module Components.Mobbers.Doc exposing (doc)

import Components.Mobbers.View
import ElmBook
import ElmBook.Actions exposing (logAction)
import ElmBook.Chapter exposing (chapter, render, withComponentList)
import ElmBook.ElmCSS exposing (Chapter)
import Model.Mobber
import Model.Role as Role


props : Components.Mobbers.View.Props (ElmBook.Msg x)
props =
    { people = [ "Pin", "Manon", "Thomas", "Pauline", "Jeff", "Amélie" ] |> toMobbers
    , roles = [ "Driver", "Navigator" ] |> List.map Role.fromString
    , onShuffle = logAction "Shuffled"
    , onRotate = logAction "Rotated"
    , onSettings = logAction "Go to Settings"
    }


doc : Chapter x
doc =
    chapter "Mobbers"
        |> withComponentList
            [ ( "Defaults"
              , Components.Mobbers.View.view props
              )
            , ( "Inversed defaults"
              , Components.Mobbers.View.view
                    { props
                        | roles = [ "Navigator", "Driver" ] |> List.map Role.fromString
                    }
              )
            , ( "Too many specials"
              , Components.Mobbers.View.view
                    { props
                        | roles =
                            [ "Navigator", "Driver", "Navigator", "Driver", "Navigator", "Driver" ]
                                |> List.map Role.fromString
                    }
              )
            , ( "No specials"
              , Components.Mobbers.View.view
                    { props | roles = [] }
              )
            , ( "Custom"
              , Components.Mobbers.View.view
                    { props
                        | roles = [ "Scribe", "Moderator", "Artist" ] |> List.map Role.fromString
                    }
              )
            , ( "Too Many real mobbers"
              , Components.Mobbers.View.view
                    { props
                        | people =
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
                                |> toMobbers
                        , roles = []
                    }
              )
            , ( "Nobody"
              , Components.Mobbers.View.view
                    { props | people = [] |> toMobbers }
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
<component with-label="Nobody"/>
"""


toMobbers : List String -> List Model.Mobber.Mobber
toMobbers =
    List.indexedMap Tuple.pair
        >> List.map
            (\( i, n ) ->
                { id = Model.Mobber.idFromString <| String.fromInt i
                , name = n
                }
            )
