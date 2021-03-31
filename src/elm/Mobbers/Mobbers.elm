module Mobbers.Mobbers exposing (..)

import Json.Decode
import Json.Encode
import Lib.ListExtras as ListExtras
import Mobbers.Mobber as Mobber exposing (Mobber)
import Random
import Random.List


type Mobbers
    = Mobbers (List Mobber)


empty : Mobbers
empty =
    Mobbers []


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
        toList mobbers ++ [ mobber ] |> Mobbers


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
    Mobbers <| aList ++ missingMembersInA


delete : Mobber -> Mobbers -> Mobbers
delete mobber mobbers =
    toList mobbers
        |> List.filter (\m -> m.id /= mobber.id)
        |> Mobbers


toList : Mobbers -> List Mobber
toList mobbers =
    case mobbers of
        Mobbers list ->
            list


rotatable : Mobbers -> Bool
rotatable mobbers =
    (List.length <| toList mobbers) >= 2


rotate : Mobbers -> Mobbers
rotate mobbers =
    toList mobbers |> ListExtras.rotate |> Mobbers


shufflable : Mobbers -> Bool
shufflable mobbers =
    (List.length <| toList mobbers) >= 3


shuffle : Mobbers -> Random.Generator Mobbers
shuffle mobbers =
    toList mobbers |> Random.List.shuffle |> Random.map Mobbers


decoder : Json.Decode.Decoder Mobbers
decoder =
    Json.Decode.list Mobber.jsonDecoder
        |> Json.Decode.map Mobbers


toJson : Mobbers -> Json.Encode.Value
toJson mobbers =
    case mobbers of
        Mobbers list ->
            Json.Encode.list Mobber.toJson list
