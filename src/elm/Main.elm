module Main exposing (..)

import Browser
import Browser.Navigation as Nav
import Html exposing (..)
import Pages.Mob.Main
import Url
import UserPreferences


-- MAIN


main : Program UserPreferences.Model Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlChange = UrlChanged
        , onUrlRequest = LinkClicked
        }



-- MODEL


type alias Model =
    { key : Nav.Key
    , url : Url.Url
    , mob : Pages.Mob.Main.Model
    }


init : UserPreferences.Model -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init preferences url key =
    Pages.Mob.Main.init preferences
        |> Tuple.mapBoth
            (\mob ->
                { key = key
                , url = url
                , mob = mob
                }
            )
            (Cmd.map GotMobMsg)



-- UPDATE


type Msg
    = LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | GotMobMsg Pages.Mob.Main.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LinkClicked _ ->
            ( model, Cmd.none )

        UrlChanged _ ->
            ( model, Cmd.none )

        GotMobMsg sub ->
            Pages.Mob.Main.update sub model.mob
                |> Tuple.mapBoth
                    (\mob -> { model | mob = mob })
                    (Cmd.map GotMobMsg)



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Pages.Mob.Main.subscriptions model.mob
        |> Sub.map GotMobMsg



-- VIEW


view : Model -> Browser.Document Msg
view model =
    let
        mobDocument =
            Pages.Mob.Main.view model.mob model.url
    in
    { title = mobDocument.title
    , body =
        mobDocument.body
            |> List.map (Html.map GotMobMsg)
    }
