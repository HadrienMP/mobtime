module Main exposing (..)

import Browser
import Browser.Navigation as Nav
import Html exposing (..)
import Lib.ListExtras
import Pages.Mob.Main
import Task
import Time
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
    let
        ( mob, mobCommand ) =
            Pages.Mob.Main.init "Awesome" preferences
    in
    ( { key = key
      , url = url
      , mob = mob
      }
    , Cmd.batch
        [ Task.perform TimePassed Time.now
        , Cmd.map GotMobMsg mobCommand
        ]
    )



-- UPDATE


type Msg
    = LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | GotMobMsg Pages.Mob.Main.Msg
    | TimePassed Time.Posix


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

        TimePassed now ->
            Pages.Mob.Main.timePassed now model.mob
                |> Tuple.mapBoth
                    (\mob -> { model | mob = mob })
                    (Cmd.map GotMobMsg)



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ Pages.Mob.Main.subscriptions |> Sub.map GotMobMsg
        , Time.every 500 TimePassed
        ]



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
