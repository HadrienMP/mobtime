module Main exposing (..)

import Browser
import Browser.Navigation as Nav
import Css
import Html.Styled as Html exposing (Html, button, div, h2, text)
import Html.Styled.Attributes exposing (class, css, id)
import Html.Styled.Events exposing (onClick)
import Js.Commands
import Js.Events
import Js.EventsMapping as EventsMapping exposing (EventsMapping)
import Lib.BatchMsg
import Lib.Toaster as Toaster
import Lib.UpdateResult as UpdateResult exposing (UpdateResult)
import Model.MobName exposing (MobName)
import Pages.Home
import Pages.Mob
import Routing
import Shared
import Spa
import UI.Icons.Ion
import UI.Modal
import UI.Palettes
import UI.Rem
import Url
import UserPreferences
import View



-- MAIN


main : Program UserPreferences.Model Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlChange = UrlChanged
        , onUrlRequest = SharedMsg << Shared.LinkClicked
        }



-- MODEL


type Page
    = Home Pages.Home.Model
    | Mob Pages.Mob.Model


type alias Model =
    { page : Page
    , displayModal : Bool
    , shared : Shared.Shared
    }


init : UserPreferences.Model -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init preferences url key =
    let
        ( shared, socketCommand ) =
            Shared.init
                { key = key
                , url = url
                , preferences = preferences
                , mob = getMob url
                }

        ( page, pageCommand ) =
            loadPage shared
    in
    ( { page = page
      , displayModal =
            case page of
                Home _ ->
                    False

                Mob _ ->
                    True
      , shared = shared
      }
    , Cmd.batch
        [ Js.Commands.send <| Js.Commands.ChangeVolume preferences.volume
        , pageCommand
        , socketCommand |> Cmd.map SharedMsg
        ]
    )


loadPage : Shared.Shared -> ( Page, Cmd Msg )
loadPage shared =
    case Routing.toPage shared.url of
        Routing.Login ->
            Pages.Home.init shared
                |> Tuple.mapBoth
                    Home
                    (Cmd.map GotHomeMsg)

        Routing.Mob mobName ->
            Pages.Mob.init mobName shared.preferences
                |> Tuple.mapBoth
                    Mob
                    (Cmd.map (GotMobMsg << Spa.Regular))



-- UPDATE


type Msg
    = GotMobMsg (Spa.Msg Pages.Mob.Msg)
    | GotHomeMsg Pages.Home.Msg
    | Batch (List Msg)
    | HideModal
    | SharedMsg Shared.Msg
    | UrlChanged Url.Url


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model.page ) of
        ( UrlChanged url, _ ) ->
            let
                shared =
                    Shared.withUrl url model.shared

                ( page, command ) =
                    loadPage shared
            in
            ( { model | page = page, shared = shared }
            , command
            )

        ( GotHomeMsg subMsg, Home subModel ) ->
            Pages.Home.update model.shared subModel subMsg
                |> UpdateResult.map Home GotHomeMsg
                |> toModelCmd model

        ( GotMobMsg (Spa.Regular subMsg), Mob subModel ) ->
            Pages.Mob.update model.shared subMsg subModel
                |> UpdateResult.map Mob (GotMobMsg << Spa.Regular)
                |> toModelCmd model

        ( GotMobMsg (Spa.Shared subMsg), _ ) ->
            Shared.update subMsg model.shared
                |> Tuple.mapBoth (\updated -> { model | shared = updated })
                    (Cmd.map SharedMsg)

        ( Batch messages, _ ) ->
            Lib.BatchMsg.update messages model update

        ( HideModal, _ ) ->
            ( { model | displayModal = False }
            , Cmd.none
            )

        ( SharedMsg subMsg, _ ) ->
            Shared.update subMsg model.shared
                |> Tuple.mapBoth (\updated -> { model | shared = updated })
                    (Cmd.map SharedMsg)

        _ ->
            ( model, Cmd.none )


getMob : Url.Url -> Maybe MobName
getMob url =
    case Routing.toPage url of
        Routing.Login ->
            Nothing

        Routing.Mob mobName ->
            Just mobName


toModelCmd : Model -> UpdateResult Page Msg -> ( Model, Cmd Msg )
toModelCmd model result =
    let
        ( shared, sharedCommand ) =
            Shared.toast result.toasts model.shared
    in
    ( { model
        | page = result.model
        , shared = shared
      }
    , Cmd.batch [ Cmd.map SharedMsg sharedCommand, result.command ]
    )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ case model.page of
            Home _ ->
                Sub.none

            Mob mobModel ->
                Pages.Mob.subscriptions mobModel |> Sub.map (GotMobMsg << Spa.Regular)
        , Js.Events.events (dispatch jsEventsMapping)
        , Shared.subscriptions model.shared |> Sub.map SharedMsg
        ]


dispatch : EventsMapping Msg -> Js.Events.Event -> Msg
dispatch mapping event =
    Batch <| EventsMapping.dispatch event mapping


jsEventsMapping : EventsMapping Msg
jsEventsMapping =
    EventsMapping.map (GotMobMsg << Spa.Regular) Pages.Mob.jsEventMapping



-- VIEW


view : Model -> Browser.Document Msg
view model =
    let
        doc =
            case model.page of
                Home sub ->
                    Pages.Home.view model.shared sub
                        |> View.map GotHomeMsg

                Mob sub ->
                    Pages.Mob.view model.shared sub
                        |> View.map GotMobMsg
    in
    { title = doc.title
    , body =
        [ Html.toUnstyled <|
            Html.div [ css [ Css.height <| Css.pct 100 ] ]
                [ Html.div [ css [ Css.height <| Css.pct 100 ] ]
                    (doc.body
                        ++ soundModal model
                        ++ (doc.modal
                                |> Maybe.map UI.Modal.withContent
                                |> Maybe.map List.singleton
                                |> Maybe.withDefault []
                           )
                        ++ [ Toaster.view model.shared.toasts |> Html.map (SharedMsg << Shared.Toast) ]
                    )
                ]
        ]
    }


soundModal : Model -> List (Html Msg)
soundModal model =
    if model.displayModal then
        [ div
            [ id "modal-container", onClick HideModal ]
            [ div [ id "modal" ]
                [ h2 [] [ text "Welcome to Mobtime !" ]
                , button
                    [ class "labelled-icon-button"
                    , onClick <| HideModal
                    ]
                    [ UI.Icons.Ion.paperAirplane
                        { size = UI.Rem.Rem 1
                        , color = UI.Palettes.monochrome.on.surface
                        }
                    , text "Let's go!"
                    ]
                ]
            ]
        ]

    else
        []
