module Mob.Tabs.Share exposing (..)

import Html exposing (Html, button, div, i, span, strong, text)
import Html.Attributes exposing (class, id, title)
import Html.Events exposing (onClick)
import Interface.Commands
import Interface.Events
import Process
import QRCode
import Svg.Attributes as Svg
import Task
import Url



-- MODEL


type alias Model =
    { lastMsg : Maybe Msg }


init : Model
init =
    { lastMsg = Nothing }



-- UPDATE


type Msg
    = PutLinkInPasteBin Url.Url
    | DisplayCopied
    | BackToNormal


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model.lastMsg ) of
        ( PutLinkInPasteBin url, Nothing ) ->
            ( { model | lastMsg = Just msg }
            , Url.toString url
                |> Interface.Commands.CopyInPasteBin
                |> Interface.Commands.send
            )

        ( DisplayCopied, Just (PutLinkInPasteBin _) ) ->
            ( { model | lastMsg = Just msg }
            , Process.sleep 5000 |> Task.perform (always BackToNormal)
            )

        ( BackToNormal, Just DisplayCopied ) ->
            ( { model | lastMsg = Nothing }
            , Process.sleep 5000 |> Task.perform (always BackToNormal)
            )

        _ ->
            ( model, Cmd.none )



-- VIEW


view : Model -> Url.Url -> Html Msg
view model url =
    div [ id "share", class "tab" ]
        [ shareButton model url
        , QRCode.fromString (Url.toString url)
            |> Result.map
                (QRCode.toSvg
                    [ Svg.width "300px"
                    , Svg.height "300px"
                    ]
                )
            |> Result.withDefault (Html.text "Error while encoding to QRCode.")
        ]


shareButton : Model -> Url.Url -> Html Msg
shareButton model url =
    button
        [ onClick <| PutLinkInPasteBin url
        , id "share-link"
        , title "Copy this mob's link in your clipboard"
        ]
        [ shareText model
        , i [ id "share-button", class "fas fa-share-alt" ] []
        ]


shareText : Model -> Html Msg
shareText model =
    case model.lastMsg of
        Just DisplayCopied ->
            span [] [ text "The url has been copied !" ]

        _ ->
            span []
                [ text "You are in the "
                , strong [] [ text "Agicap" ]
                , text " mob"
                ]
