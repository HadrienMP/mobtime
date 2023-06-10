module Pages.Mob.Bug exposing (doc)

import Components.SecondaryPage.View
import Css
import ElmBook.Actions exposing (logAction)
import ElmBook.Chapter exposing (chapter, renderComponent)
import ElmBook.ElmCSS exposing (Chapter)
import Html.Styled as Html
import Html.Styled.Attributes as Attr
import UI.Button.Link
import UI.Typography.Typography as Typography


doc : Chapter x
doc =
    chapter "Bug"
        |> renderComponent
            (Components.SecondaryPage.View.view
                { onBack = logAction "Back"
                , title = "Found a bug?"
                , content =
                    Html.div []
                        [ Html.p
                            [ Attr.css
                                [ Css.fontWeight Css.lighter
                                ]
                            ]
                            [ Html.text "Help make mobtime better by reporting it!" ]
                        , Html.p []
                            [ Html.text "1. "
                            , UI.Button.Link.view [ Attr.css [ Typography.fontSize Typography.m ] ]
                                { text = Html.text " Display the event log "
                                , onClick = logAction "Display the event log"
                                }
                            , Html.text " and save it into a json file (events.json for example)"
                            ]
                        , Html.p []
                            [ Html.text "2. Then go to github to "
                            , Html.a
                                [ Attr.href "https://github.com/HadrienMP/mobtime/issues/new?assignees=&labels=&projects=&template=bug_report.md&title="
                                , Attr.target "_blank"
                                ]
                                [ Html.text "report the issue" ]
                            ]
                        ]
                }
            )
