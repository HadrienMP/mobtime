module Page.Join exposing (..)
import Browser
import Browser.Navigation as Nav
import Html exposing (Html, button, dd, div, dl, dt, h1, h2, header, hr, input, text)
import Html.Attributes exposing (class, placeholder, required, type_)
import Html.Events exposing (onInput, onSubmit)
import Http
import Http.Detailed
import Identity
import Json.Decode
import Json.Encode
import Mob exposing (MobName)
import NEString exposing (NEString)
import Session exposing (Session)
import Tools exposing (httpErrorToString)
import Validation exposing (ValidationResult)


type alias Stats =
    { mobs: Int
    , mobbers: Int
    }

statsDecoder =
    Json.Decode.map2
        Stats
        (Json.Decode.field "mobs" Json.Decode.int)
        (Json.Decode.field "mobbers" Json.Decode.int)


type alias Model =
    { mobName: ValidationResult NEString
    , stats: Maybe Stats
    }

type Msg
    = MobNameChanged (ValidationResult NEString)
    | JoinMobRequest
    | JoinMobResponse (Result (Http.Detailed.Error String) ( Http.Metadata, Maybe MobName ))
    | GotStats (Result Http.Error Stats)

init : (Model, Cmd Msg)
init =
    ( { mobName = Validation.initial, stats = Nothing }
    , Http.get
        { url = "/api/stats"
        , expect = Http.expectJson GotStats statsDecoder
        }
    )

update : Session -> Model -> Msg -> (Model -> model) -> (Msg -> msg) -> (model, Cmd msg)
update session model msg toMainModel toMainMsg =
    Tuple.mapBoth toMainModel (Cmd.map toMainMsg)
    <| case msg of
        GotStats statsResult ->
            case statsResult of
                Ok stats -> ({model | stats = Just stats}, Cmd.none)
                Err error -> Debug.log (httpErrorToString error) (model, Cmd.none)
        JoinMobRequest ->
            case model.mobName of
                Validation.Valid name ->
                    (model
                    , Http.post
                        { url = "/api/mob"
                        , body = Http.jsonBody (Json.Encode.object [("name", Json.Encode.string <| NEString.toString name)])
                        , expect = Http.Detailed.expectJson JoinMobResponse mobDecoder
                        }
                    )

                -- todo handle error ?
                _ -> (model, Cmd.none)
        JoinMobResponse result ->
            case result of
                Ok (_, maybeName) ->
                    case maybeName of
                        Just name ->
                            (model, Nav.pushUrl session.key <| "/mob/" ++ NEString.toString name)
                        Nothing ->
                            -- todo handle error
                            (model, Cmd.none)
                Err error ->
                    let
                        _ = case error of
                                Http.Detailed.BadStatus _ body -> Debug.log body
                                _ -> Debug.log "wut ?"
                    in
                        -- todo handle error
                        (model, Cmd.none)


        MobNameChanged result ->
                    ({model | mobName = result}, Cmd.none)

mobDecoder : Json.Decode.Decoder (Maybe MobName)
mobDecoder =
    Json.Decode.field "name" Json.Decode.string
    |> Json.Decode.map NEString.from


view : Model -> Identity.Model -> (Msg -> a) -> (Identity.Msg -> a) -> Browser.Document a
view model identity toMainMsg identityMsgToMain =
    { title = "Mob Time !"
    , body =
        [ header [] [ h1 [] [text "Mob Time !"] ]
        , div [ class "box" ]
              [ Html.form [ onSubmit (toMainMsg JoinMobRequest) ]
                  [ Identity.view identity identityMsgToMain
                  , div [ class "text-field" ]
                        [ div [ class "form-error" ]
                              [ Validation.message model.mobName |> Maybe.withDefault "" |> text ]
                        , input
                            [ type_ "text"
                            , placeholder "What is your mob called ?"
                            , required True
                            , onInput (Validation.validate mobNameRules >> MobNameChanged >> toMainMsg)
                            ]
                            []
                        ]
                  , button [] [text "Join"]
                  ]
              ]
        , (Maybe.map statsView model.stats |> Maybe.withDefault (div [] []) )
        ]
    }

statsView : Stats -> Html a
statsView stats =
    div
        [ class "box"]
        [ h2 [] [ text "Stats"]
        , dl
            []
            [ dt [] [text "Number of active mobs"]
            , dd [] [ text <| String.fromInt stats.mobs ]
            ,  dt [] [text "Number of active mobbers"]
            , dd [] [ text <| String.fromInt stats.mobbers ]
            ]
        ]

mobNameRules : String -> Result String NEString
mobNameRules raw =
    NEString.from raw
    |> Result.fromMaybe "Your mob name cannot be empty"