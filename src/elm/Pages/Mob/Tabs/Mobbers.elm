module Pages.Mob.Tabs.Mobbers exposing (Model, Msg(..), init, update, view)

import Css
import Effect exposing (Effect)
import Field
import Field.String
import Html as Unstyled
import Html.Attributes as UnstyledAttr
import Html.Events as UnstyledEvts
import Html.Styled as Html exposing (Html, button, div, form, li, p, text, ul)
import Html.Styled.Attributes as Attr exposing (class, id, type_)
import Html.Styled.Events exposing (onClick, onSubmit)
import Lib.Toaster as Toaster
import Model.Events
import Model.Mob exposing (Mob)
import Model.MobName exposing (MobName)
import Model.Mobber exposing (Mobber)
import Model.Mobbers as Mobbers exposing (Mobbers)
import Model.Role exposing (Role)
import Random
import Shared
import UI.Button.View
import UI.Css
import UI.Icons.Ion as Icons
import UI.Palettes as Palettes
import UI.Size as Size
import Uuid


type alias Model =
    { mobberName : Field.String.Field }


init : Model
init =
    { mobberName = Field.init "" }



-- UPDATE


type Msg
    = NameChanged String
    | StartAdding
    | Add Mobber
    | Shuffle
    | ShareEvent Model.Events.Event


update : Msg -> Mobbers -> MobName -> Model -> ( Model, Effect Shared.Msg Msg )
update msg mobbers mob model =
    case msg of
        NameChanged name ->
            ( { model
                | mobberName =
                    name
                        |> Field.resetValue model.mobberName
                        |> Field.String.notEmpty
              }
            , Effect.none
            )

        StartAdding ->
            let
                name =
                    model.mobberName |> Field.String.notEmpty
            in
            case Field.toResult name of
                Ok validMobberName ->
                    ( { model | mobberName = Field.init "" }
                    , Effect.fromCmd <|
                        Random.generate
                            (\id ->
                                Add
                                    { id = id |> Uuid.toString |> Model.Mobber.idFromString
                                    , name = validMobberName
                                    }
                            )
                            Uuid.uuidGenerator
                    )

                Err _ ->
                    ( { model | mobberName = name }
                    , Shared.toast <| Toaster.error "The mobber name cannot be empty"
                    )

        Add mobber ->
            ( model
            , mobber
                |> Model.Events.AddedMobber
                |> Model.Events.MobEvent mob
                |> Effect.share
            )

        Shuffle ->
            ( model
            , Effect.fromCmd <|
                Random.generate (ShareEvent << Model.Events.ShuffledMobbers) <|
                    Mobbers.shuffle mobbers
            )

        ShareEvent event ->
            -- TODO duplicated code
            ( model
            , event
                |> Model.Events.MobEvent mob
                |> Effect.share
            )



-- VIEW


view : Mob -> Model -> Html Msg
view { mobbers, roles } model =
    div
        [ id "mobbers"
        , class "tab"
        , Attr.css
            [ Css.displayFlex
            , Css.flexDirection Css.column
            , UI.Css.gap <| Size.rem 1
            ]
        ]
        [ form
            [ id "add", onSubmit StartAdding ]
            [ Field.view (textFieldConfig "Mobber to be added" NameChanged) model.mobberName
                |> Html.fromUnstyled
            , button [ type_ "submit" ]
                [ Icons.plus
                    { size = Size.rem 1
                    , color = Palettes.monochrome.on.surface
                    }
                ]
            ]
        , div
            [ Attr.css
                [ Css.displayFlex
                , Css.width <| Css.pct 100
                , UI.Css.gap <| Size.rem 0.4
                ]
            ]
            [ UI.Button.View.button [ Attr.css [ Css.flexGrow <| Css.int 1 ] ]
                { content = UI.Button.View.Both { icon = Icons.rotate, text = "Rotate" }
                , action =
                    UI.Button.View.OnPress <|
                        if Mobbers.rotatable mobbers then
                            Just <| ShareEvent <| Model.Events.RotatedMobbers

                        else
                            Nothing
                , variant = UI.Button.View.Primary
                , size = UI.Button.View.S
                }
            , UI.Button.View.button [ Attr.css [ Css.flexGrow <| Css.int 1 ] ]
                { content = UI.Button.View.Both { icon = Icons.shuffle, text = "Shuffle" }
                , action =
                    UI.Button.View.OnPress <|
                        if Mobbers.shufflable mobbers then
                            Just <| Shuffle

                        else
                            Nothing
                , variant = UI.Button.View.Primary
                , size = UI.Button.View.S
                }
            ]
        , ul
            [ Attr.css
                [ Css.displayFlex
                , Css.flexDirection Css.column
                , UI.Css.gap <| Size.rem 1
                ]
            ]
            (Mobbers.assignRoles roles mobbers
                |> List.map mobberView
            )
        ]


textFieldConfig : String -> (String -> msg) -> Field.String.ViewConfig msg
textFieldConfig title toMsg =
    { valid =
        \meta value ->
            Unstyled.div [ UnstyledAttr.class "form-field" ]
                [ textInput title toMsg value meta ]
    , invalid =
        \meta value _ ->
            Unstyled.div [ UnstyledAttr.class "form-field" ]
                [ textInput title toMsg value meta
                ]
    }


textInput : String -> (String -> msg) -> String -> { a | disabled : Bool } -> Unstyled.Html msg
textInput title toMsg value meta =
    Unstyled.input
        [ UnstyledEvts.onInput toMsg
        , UnstyledAttr.type_ "text"
        , UnstyledAttr.placeholder title
        , UnstyledAttr.value value
        , UnstyledAttr.disabled meta.disabled
        ]
        []


mobberView : ( Role, Mobber ) -> Html Msg
mobberView ( role, mobber ) =
    li []
        [ p [ class "role" ] [ text <| Model.Role.print role ]
        , div
            []
            [ p [ class "name" ] [ text mobber.name ]
            , button
                [ onClick <| ShareEvent <| Model.Events.DeletedMobber mobber ]
                [ Icons.delete
                    { size = Size.rem 1
                    , color = Palettes.monochrome.on.background
                    }
                ]
            ]
        ]
