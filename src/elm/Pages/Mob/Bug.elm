port module Pages.Mob.Bug exposing (Msg(..), doc, update, view)

import Components.SecondaryPage
import Css
import Effect exposing (Effect)
import ElmBook.Actions exposing (logAction)
import ElmBook.Chapter exposing (chapter, renderComponent)
import ElmBook.ElmCSS exposing (Chapter)
import Html.Styled as Html
import Html.Styled.Attributes as Attr
import Shared exposing (Shared)
import UI.Button.Link
import UI.Css
import UI.Space
import UI.Typography as Typography
import View


port displayLogs : () -> Cmd msg



-- Doc


doc : Chapter x
doc =
    chapter "Bug"
        |> renderComponent
            (internalView
                { onDisplayLogs = logAction "Display the event log"
                , onBack = logAction "Back"
                }
            )



-- Page
-- Update


type Msg
    = Back
    | DisplayLogs


update : Shared -> Msg -> Effect Shared.Msg Msg
update shared msg =
    case msg of
        Back ->
            Shared.backToMob shared

        DisplayLogs ->
            displayLogs () |> Effect.fromCmd



-- View


view : View.View Msg
view =
    { title = "Found a bug?"
    , modal = Nothing
    , body =
        internalView { onBack = Back, onDisplayLogs = DisplayLogs }
    }


type alias Props msg =
    { onDisplayLogs : msg
    , onBack : msg
    }


internalView : Props msg -> Html.Html msg
internalView props =
    Components.SecondaryPage.view
        { onBack = props.onBack
        , title = "Found a bug?"
        , subTitle = Just "Help make mobtime better by reporting it!"
        , content =
            Html.div
                [ Attr.css
                    [ Css.displayFlex
                    , Css.flexDirection Css.column
                    , UI.Css.gap UI.Space.s
                    ]
                ]
                [ Html.div []
                    [ Html.p []
                        [ Html.text "1. "
                        , UI.Button.Link.view [ Attr.css [ Typography.fontSize Typography.m ] ]
                            { text = Html.text " Display the event log "
                            , onClick = props.onDisplayLogs
                            }
                        , Html.text " and save it into a json file (events.json for example)"
                        ]
                    , Html.p []
                        [ Html.text "2. Then go to github to "
                        , Html.a
                            [ Attr.href "https://github.com/HadrienMP/mobtime/issues/new?assignees=&labels=bug&projects=&template=bug_report.md&title="
                            , Attr.target "_blank"
                            ]
                            [ Html.text "report the issue" ]
                        ]
                    ]
                , Html.p [ Attr.css [ Css.fontWeight Css.lighter ] ]
                    [ Html.text "Thank you for helping!"
                    ]
                ]
        }
