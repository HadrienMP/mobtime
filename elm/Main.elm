port module Main exposing (..)

import Browser
import Browser.Navigation as Nav
import Html exposing (Html, a, button, div, form, h1, h2, i, input, label, li, nav, option, p, select, text, ul)
import Html.Attributes exposing (class, classList, for, href, id, placeholder, type_, value)
import Json.Encode
import Url



-- MAIN


main : Program String Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlChange = UrlChanged
        , onUrlRequest = LinkClicked
        }


port store : Json.Encode.Value -> Cmd msg



-- MODEL


type TabType
    = Timer
    | Mobbers
    | Settings


type alias Tab =
    { type_ : TabType
    , url : String
    , name : String
    , icon : String
    }


timerPage : Tab
timerPage =
    Tab Timer "/timer" "Timer" "fa-clock"


pages : List Tab
pages =
    [ timerPage
    , Tab Mobbers "/mobbers" "Mobbers" "fa-users"
    , Tab Settings "/settings" "Settings" "fa-cog"
    ]


type alias Model =
    { key : Nav.Key
    , url : Url.Url
    , tab : Tab
    , nickName : String
    }


init : String -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init nickname url key =
    ( Model key url (pageFrom url |> Maybe.withDefault timerPage) nickname, Cmd.none )


pageFrom : Url.Url -> Maybe Tab
pageFrom url =
    pages
        |> List.filter (\p -> p.url == url.path)
        |> List.head



-- UPDATE


type Msg
    = LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LinkClicked urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Nav.pushUrl model.key (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        UrlChanged url ->
            ( { model | url = url, tab = pageFrom url |> Maybe.withDefault timerPage }
            , Cmd.none
            )



--_ ->
--    ( model, Cmd.none )
-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : Model -> Browser.Document Msg
view model =
    { title = "Mob Time !"
    , body =
        [ div
            [ id "container" ]
            [ nav [] <| navLinks model.url
            , case model.tab.type_ of
                Mobbers ->
                    mobbersView model

                Settings ->
                    settingsView model

                _ ->
                    p [] [ text "I don't know this page..." ]
            ]
        ]
    }


navLinks : Url.Url -> List (Html msg)
navLinks current =
    List.map
        (\page ->
            a
                [ href page.url, classList [ activeClass current page.url ] ]
                [ i [ class <| "fas " ++ page.icon ] [] ]
        )
        pages


activeClass : Url.Url -> String -> ( String, Bool )
activeClass current tabUrl =
    ( "active", current.path == tabUrl )


mobbersView : Model -> Html msg
mobbersView model =
    div [ id "mobbers", class "tab" ]
        [ div
            [ id "add" ]
            [ input [ type_ "text", placeholder "Mobber name" ] []
            , button [] [ i [ class "fas fa-plus" ] [] ]
            ]
        , ul
            []
            [ li []
                [ i [ class "fas fa-bars" ] []
                , div
                    []
                    [ p [] [ text "Navigator" ]
                    , input [ type_ "text", value "John" ] []
                    ]
                ]
            , li []
                [ i [ class "fas fa-bars" ] []
                , div
                    []
                    [ p [] [ text "Navigator" ]
                    , input [ type_ "text", value "Jane" ] []
                    ]
                ]
            ]
        ]


settingsView : Model -> Html msg
settingsView model =
    div [ id "settings", class "tab" ]
        [ div []
            [ h2 []
                [ i [ class "fas fa-share-alt" ] []
                , text " Shared with the mob"
                ]
            , form
                []
                [ label [ for "length" ] [ text "Turn length (min)" ]
                , input [ id "length", type_ "number", Html.Attributes.min "1", Html.Attributes.max "99", value "4" ] []
                , label [ for "turns" ] [ text "Number of turns before break" ]
                , input [ id "turns", type_ "number", Html.Attributes.min "1", Html.Attributes.max "9", value "6" ] []
                , label [ for "roles" ] [ text "Roles" ]
                , input [ id "roles", type_ "text", value "Driver, Mavigator" ] []
                , label [ for "theme" ] [ text "Sounds" ]
                , select
                    []
                    [ option [] [ text "Classic" ] ]
                ]
            ]
        , div []
            [ h2 []
                [ i [ class "fas fa-user-lock" ] []
                , text " Private"
                ]
            , form
                []
                [ label [ for "volume" ] [ text "Volume" ]
                , input
                    [ id "length", type_ "range", Html.Attributes.min "0", Html.Attributes.max "100", value "60" ]
                    []
                ]
            ]
        ]
