module Model.Mobbers exposing
    ( Mobbers
    , add
    , assignRoles
    , decoder
    , delete
    , empty
    , merge
    , moveDown
    , moveUp
    , rotate
    , shuffle
    , toJson
    , toList
    )

import Json.Decode as Decode
import Json.Encode as Json
import Lib.ListExtras as ListExtras
import Model.Mobber as Mobber exposing (Mobber)
import Model.Role as Role exposing (Role)
import Model.Roles exposing (Roles)
import Random
import Random.List


type alias Mobbers =
    List Mobber


empty : Mobbers
empty =
    []


add : Mobber -> Mobbers -> Mobbers
add mobber mobbers =
    let
        alreadyExists =
            toList mobbers
                |> List.map .id
                |> List.member mobber.id
    in
    if alreadyExists then
        mobbers

    else
        toList mobbers ++ [ mobber ]


merge : Mobbers -> Mobbers -> Mobbers
merge a b =
    let
        aList =
            toList a

        bList =
            toList b

        missingMembersInA =
            List.filter (\someB -> not <| List.member someB aList) bList
    in
    aList ++ missingMembersInA


delete : Mobber -> Mobbers -> Mobbers
delete mobber mobbers =
    toList mobbers
        |> List.filter (\m -> m.id /= mobber.id)


toList : Mobbers -> List Mobber
toList mobbers =
    mobbers


assignRoles : Roles -> Mobbers -> List ( Role, Mobber )
assignRoles roles mobbers =
    let
        list =
            toList mobbers
    in
    list
        |> ListExtras.zip
            (roles
                ++ List.repeat (List.length list - List.length roles) Role.none
            )


rotate : Mobbers -> Mobbers
rotate =
    ListExtras.rotate


moveUp : Mobber -> Mobbers -> Mobbers
moveUp target all =
    moveUpRec target { seen = [], toSee = all }


moveUpRec : Mobber -> { seen : List Mobber, toSee : List Mobber } -> List Mobber
moveUpRec target { seen, toSee } =
    case toSee of
        [] ->
            seen ++ toSee

        [ _ ] ->
            seen ++ toSee

        a :: b :: rest ->
            if b == target then
                seen ++ (b :: a :: rest)

            else
                moveUpRec target { seen = seen ++ [ a ], toSee = b :: rest }


moveDown : Mobber -> Mobbers -> Mobbers
moveDown target all =
    moveDownRec target { seen = [], toSee = all }


moveDownRec : Mobber -> { seen : List Mobber, toSee : List Mobber } -> List Mobber
moveDownRec target { seen, toSee } =
    case toSee of
        [] ->
            seen ++ toSee

        [ _ ] ->
            seen ++ toSee

        a :: b :: rest ->
            if a.id == target.id then
                seen ++ (b :: a :: rest)

            else
                moveDownRec target { seen = seen ++ [ a ], toSee = b :: rest }


shuffle : Mobbers -> Random.Generator Mobbers
shuffle =
    Random.List.shuffle


decoder : Decode.Decoder Mobbers
decoder =
    Decode.list Mobber.jsonDecoder


toJson : Mobbers -> Json.Value
toJson =
    Json.list Mobber.toJson
