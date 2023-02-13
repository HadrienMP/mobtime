module Main exposing (..)

import Browser
import Browser.Navigation as Nav
import Css
import Effect exposing (Effect)
import Html.Styled as Html
import Html.Styled.Attributes exposing (css)
import Js.Commands
import Js.Events
import Js.EventsMapping as EventsMapping exposing (EventsMapping)
import Json.Decode as Decode
import Lib.BatchMsg
import Lib.Toaster as Toaster
import Model.Events
import Model.MobName exposing (MobName)
import Pages.Home
import Pages.Mob
import Pages.Mob.Share.Page
import Pages.Profile.Page
import Routing
import Shared
import UI.GlobalStyle
import UI.Layout
import UI.Modal.View
import Url
import View



-- MAIN


main : Program Decode.Value Model Msg
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
    | MobShare MobName
    | Profile


type alias Model =
    { page : Page
    , shared : Shared.Shared
    }


init : Decode.Value -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init jsonPreferences url key =
    let
        ( shared, sharedCommand ) =
            Shared.init
                { key = key
                , url = url
                , jsonPreferences = jsonPreferences
                , mob = getMob url
                }

        ( page, pageCommand ) =
            loadPage shared

        ( model, command ) =
            ( { page = page, shared = shared }, pageCommand )
                |> handleEffect
    in
    ( model
    , Cmd.batch [ command, sharedCommand |> Cmd.map SharedMsg ]
    )


loadPage : Shared.Shared -> ( Page, Effect Shared.Msg Msg )
loadPage shared =
    case Routing.toPage shared.url of
        Routing.Login ->
            Pages.Home.init
                |> Tuple.mapBoth
                    Home
                    (Effect.map GotHomeMsg)

        Routing.Mob mobName ->
            Pages.Mob.init shared mobName
                |> Tuple.mapBoth
                    Mob
                    (Effect.map GotMobMsg)

        Routing.Share mobName ->
            ( MobShare mobName
            , Effect.none
            )

        Routing.Profile ->
            ( Profile, Effect.none )



-- UPDATE


type Msg
    = GotMobMsg Pages.Mob.Msg
    | GotHomeMsg Pages.Home.Msg
    | MobShareMsg Pages.Mob.Share.Page.Msg
    | ProfileMsg Pages.Profile.Page.Msg
    | Batch (List Msg)
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
                |> handleEffect

        ( GotHomeMsg subMsg, Home subModel ) ->
            Pages.Home.update model.shared subModel subMsg
                |> Tuple.mapBoth
                    (\updated -> { model | page = Home updated })
                    (Effect.map GotHomeMsg)
                |> handleEffect

        ( GotMobMsg subMsg, Mob subModel ) ->
            Pages.Mob.update model.shared subMsg subModel
                |> Tuple.mapBoth
                    (\updated -> { model | page = Mob updated })
                    (Effect.map GotMobMsg)
                |> handleEffect

        ( MobShareMsg subMsg, MobShare mob ) ->
            Pages.Mob.Share.Page.update model.shared subMsg mob
                |> Effect.map MobShareMsg
                |> Tuple.pair model
                |> handleEffect

        ( ProfileMsg subMsg, Profile ) ->
            ( model
            , Pages.Profile.Page.update subMsg model.shared
                |> Effect.map ProfileMsg
            )
                |> handleEffect

        ( Batch messages, _ ) ->
            Lib.BatchMsg.update messages model update

        ( SharedMsg subMsg, _ ) ->
            Shared.update subMsg model.shared
                |> Tuple.mapBoth (\updated -> { model | shared = updated })
                    (Cmd.map SharedMsg)

        _ ->
            ( model, Cmd.none )


handleEffect : ( Model, Effect Shared.Msg Msg ) -> ( Model, Cmd Msg )
handleEffect ( model, effect ) =
    case effect of
        Effect.Atomic atomic ->
            handleAtomicEffect model atomic

        Effect.Batch effects ->
            handleBatchEffects effects ( model, Cmd.none )


handleBatchEffects :
    List (Effect.Atomic Shared.Msg Msg)
    -> ( Model, Cmd Msg )
    -> ( Model, Cmd Msg )
handleBatchEffects effects ( model, command ) =
    case effects of
        effect :: rest ->
            handleBatchEffects rest
                (handleAtomicEffect model effect
                    |> Tuple.mapSecond (\a -> Cmd.batch [ a, command ])
                )

        [] ->
            ( model, command )


handleAtomicEffect : Model -> Effect.Atomic Shared.Msg Msg -> ( Model, Cmd Msg )
handleAtomicEffect model effect =
    case effect of
        Effect.Shared msg ->
            Shared.update msg model.shared
                |> Tuple.mapBoth
                    (\updated -> { model | shared = updated })
                    (Cmd.map SharedMsg)

        Effect.Js js ->
            ( model, Js.Commands.send js )

        Effect.Command command ->
            ( model, command )

        Effect.None ->
            ( model, Cmd.none )

        Effect.MobEvent event ->
            ( model, Model.Events.sendEvent <| Model.Events.mobEventToJson event )


getMob : Url.Url -> Maybe MobName
getMob url =
    case Routing.toPage url of
        Routing.Mob mobName ->
            Just mobName

        Routing.Share mob ->
            Just mob

        _ ->
            Nothing



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ case model.page of
            Home _ ->
                Sub.none

            Mob mobModel ->
                Pages.Mob.subscriptions mobModel |> Sub.map GotMobMsg

            MobShare _ ->
                Pages.Mob.Share.Page.subscriptions |> Sub.map MobShareMsg

            Profile ->
                Sub.none
        , Js.Events.events (dispatch jsEventsMapping)
        , Shared.subscriptions model.shared |> Sub.map SharedMsg
        ]


dispatch : EventsMapping Msg -> Js.Events.Event -> Msg
dispatch mapping event =
    Batch <| EventsMapping.dispatch event mapping


jsEventsMapping : EventsMapping Msg
jsEventsMapping =
    EventsMapping.map GotMobMsg Pages.Mob.jsEventMapping



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

                MobShare mob ->
                    Pages.Mob.Share.Page.view model.shared mob
                        |> View.map MobShareMsg

                Profile ->
                    Pages.Profile.Page.view model.shared
                        |> View.map ProfileMsg

        layout =
            case model.page of
                Home _ ->
                    UI.Layout.forHome

                _ ->
                    UI.Layout.wrap
    in
    { title = doc.title
    , body =
        [ Html.toUnstyled <|
            Html.div
                [ css
                    [ Css.displayFlex
                    , Css.flexDirection Css.column
                    , Css.height <| Css.pct 100
                    ]
                ]
                (UI.GlobalStyle.globalStyle
                    :: layout model.shared doc.body
                    :: (doc.modal
                            |> Maybe.map UI.Modal.View.view
                            |> Maybe.map List.singleton
                            |> Maybe.withDefault []
                       )
                    ++ [ Toaster.view model.shared.toasts |> Html.map (SharedMsg << Shared.Toast) ]
                )
        ]
    }
