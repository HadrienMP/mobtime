module Page.Mob exposing (..)
import Browser
import Browser.Navigation
import Bytes exposing (Bytes)
import Html exposing (Html, a, button, div, h2, header, i, input, li, nav, strong, text, ul)
import Html.Attributes exposing (class, href, id, placeholder, required, type_, value)
import Html.Events exposing (onBlur, onClick, onInput)
import Http
import Http.Detailed exposing (Error)
import Identity
import Mob exposing (MobName, Mobber, MobberId, Mobbers)
import NEString exposing (NEString)
import Routes
import Session exposing (Session)
import Validation exposing (ValidationResult)

type Msg
    = IdentifyReq
    | IdentifyRes (Result (Error Bytes) ())

    | MobberAdded (Mobber, Mobbers)
    | MobberLeft (Mobber, Mobbers)
    | Leave
    | Left (Result (Error Bytes) ())

    | RolesChanged String
    | ChangeRolesReq
    | ChangeRolesRes (Result (Error Bytes) ())


type alias Role = String
type alias Roles = List Role

type alias Model =
    { mob: MobName
    , mobbers: Mobbers
    , roles : Roles
    }

init : MobName -> Session -> (Model, Cmd Msg)
init mob session =
    ( { mob = mob
      , mobbers = []
      , roles = ["Driver", "Navigator"]
      }
      , identificationRequest mob session.identity
    )

identificationRequest : MobName -> Identity.Model -> Cmd Msg
identificationRequest mob identity =
    case (identity.id, identity.nickname) of
        (Just id, Just name) ->
            Http.post
                { url = "/api/mob/" ++ NEString.toString mob ++ "/mobber"
                , body = Http.jsonBody (Mobber name id |> Mob.mobberEncoder)
                , expect = Http.Detailed.expectWhatever IdentifyRes
                }
        (_,_) -> Cmd.none

-- ###############################
-- UPDATE
-- ###############################

update : Model -> Msg -> Session -> (Model, Cmd Msg)
update model msg session =
    case msg of
        MobberAdded (_, mobbers) ->
            ( { model | mobbers = mobbers }
            , Cmd.none
            )
        MobberLeft (mobber, mobbers) ->
            ( { model | mobbers = mobbers }
            , if isItMe mobber session then Browser.Navigation.pushUrl session.key "/" else Cmd.none
            )
        Leave ->
            case session.identity.id of
                Just id ->
                    ( model
                    , Http.request
                        { method = "DELETE"
                        , headers = []
                        , url = "/api/mob/" ++ NEString.toString model.mob ++ "/mobber/" ++ id
                        , body = Http.emptyBody
                        , expect = Http.Detailed.expectWhatever Left
                        , timeout = Nothing
                        , tracker = Nothing
                        }
                    )
                Nothing -> (model, Cmd.none)
        Left _ ->
            (model, Browser.Navigation.pushUrl session.key "/")

        _ -> (model, Cmd.none )

isItMe : Mobber -> Session -> Bool
isItMe mobber session =
    case session.identity.id of
        Nothing -> False
        Just id -> id == mobber.id


-- ###############################
-- VIEW
-- ###############################

view : Model -> Session -> (Msg -> a) -> (Identity.Msg -> a) -> Browser.Document a
view model session toMain identityMsgToMain =
    { title = NEString.toString model.mob ++ " - Mob Time !"
    , body =
        [ div
            [ id "mob" ]
            (bodyView model session toMain identityMsgToMain)
        ]
    }

bodyView : Model -> Session -> (Msg -> a) -> (Identity.Msg -> a) -> List (Html a)
bodyView model session toMain identityMsgToMain =
    [ nav
        []
        [ a [ onClick <| toMain <| Leave ] [ i [ class "fas fa-home" ] [] ]
        , a [ href (Routes.mobbersUrl model.mob) ] [ i [ class "fas fa-clock" ] [] ]
        , a [] [ i [ class "fas fa-users" ] [] ]
        , a [] [ i [ class "fas fa-id-card" ] [] ]
        ]
    , header
        []
        [ h2
            []
            [ text "You are in the "
            , strong [] [ text <| NEString.toString model.mob ]
            , text " mob"]
            ]
    , div
        [ class "box" ]
        [ Identity.view
            session.identity
            identityMsgToMain
        , div
            [ class "text-field" ]
            [ input
                [ type_ "text"
                , onInput (RolesChanged >> toMain)
                , onBlur <| toMain ChangeRolesReq
                , placeholder "Driver,Navigator"
                ]
                []
            ]
        , ul
            [id "mobbers"]
            ( List.map
                (\mobber -> li [] [ NEString.toString mobber.name |> text ])
                model.mobbers
            )
        ]
    ]

identityView : Session -> (Msg -> a) -> (Identity.Msg -> a) -> Html a
identityView session toMain identityMsgToMain =
    div [ class "text-field" ]
        [ div
            [ class "form-error" ]
            [ Validation.message session.identity.nicknameField |> Maybe.withDefault "" |> text ]
        , input
            [ type_ "text"
            , required True
            , onInput (Validation.validate mobberNameRules >> Identity.NicknameChanged >> identityMsgToMain)
            , onBlur <| toMain IdentifyReq
            , placeholder "How should we call you ?"
            , value (Validation.toString NEString.toString session.identity.nicknameField)
            ]
            []
        ]

mobberNameRules : String -> Result String NEString
mobberNameRules raw =
    NEString.from raw
    |> Result.fromMaybe "Your nickname cannot be empty"