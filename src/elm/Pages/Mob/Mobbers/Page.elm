module Pages.Mob.Mobbers.Page exposing (Model, Msg(..), init, update, view)

import Effect exposing (Effect)
import Model.Events
import Model.Mob exposing (Mob)
import Model.Mobber exposing (Mobber)
import Model.Mobbers
import Pages.Mob.Mobbers.PageView
import Pages.Mob.Routing
import Random
import Routing
import Shared
import Uuid
import View exposing (View)



-- Init


type alias Model =
    { value : String }


init : Model
init =
    { value = "" }



-- Update


type Msg
    = Back
    | Rotate
    | Shuffle
    | Shuffled Model.Mobbers.Mobbers
    | Delete Mobber
    | Add
    | Created Mobber
    | NameChanged String


update : Shared.Shared -> Mob -> Msg -> Model -> ( Model, Effect Shared.Msg Msg )
update shared mob msg model =
    case msg of
        Back ->
            ( model
            , Shared.pushUrl shared <|
                Routing.Mob
                    { name = mob.name
                    , subRoute = Pages.Mob.Routing.Home
                    }
            )

        Rotate ->
            ( model
            , Effect.share
                { mob = mob.name
                , content = Model.Events.RotatedMobbers
                }
            )

        Shuffle ->
            ( model
            , Model.Mobbers.shuffle mob.mobbers
                |> Random.generate Shuffled
                |> Effect.fromCmd
            )

        Shuffled mobbers ->
            ( model
            , Effect.share
                { mob = mob.name
                , content = Model.Events.ShuffledMobbers mobbers
                }
            )

        Delete mobber ->
            ( model
            , Effect.share
                { mob = mob.name
                , content = Model.Events.DeletedMobber mobber
                }
            )

        Add ->
            ( init
            , Uuid.uuidGenerator
                |> Random.map
                    (\id ->
                        { id = Model.Mobber.idFromString <| Uuid.toString id
                        , name = model.value
                        }
                    )
                |> Random.generate Created
                |> Effect.fromCmd
            )

        Created mobber ->
            ( model
            , Effect.share
                { mob = mob.name
                , content = Model.Events.AddedMobber mobber
                }
            )

        NameChanged name ->
            ( { model | value = name }, Effect.none )



-- View


view : Mob -> Model -> View Msg
view mob model =
    { title = "Mobbers"
    , modal = Nothing
    , body =
        Pages.Mob.Mobbers.PageView.view
            { people = mob.mobbers |> Model.Mobbers.toList
            , roles = mob.roles.special
            , onShuffle = Shuffle
            , onRotate = Rotate
            , onDelete = Delete
            , onBack = Back
            , mob = mob.name
            , input = { value = model.value, onChange = NameChanged, onSubmit = Add }
            }
    }
