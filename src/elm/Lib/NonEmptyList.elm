module Lib.NonEmptyList exposing (NonEmptyList, member, toggle)

import List


type alias NonEmptyList a =
    ( a, List a )


member : a -> NonEmptyList a -> Bool
member el =
    toList >> List.member el


add : a -> NonEmptyList a -> NonEmptyList a
add el ( first, rest ) =
    ( first, el :: rest )


toList : NonEmptyList a -> List a
toList ( first, rest ) =
    first :: rest


fromList : List a -> Maybe (NonEmptyList a)
fromList list =
    case list of
        first :: rest ->
            Just ( first, rest )

        _ ->
            Nothing


toggle : a -> NonEmptyList a -> NonEmptyList a
toggle el list =
    if member el list then
        filter (\a -> a /= el) list

    else
        add el list


filter : (a -> Bool) -> NonEmptyList a -> NonEmptyList a
filter predicate list =
    list
        |> toList
        |> List.filter predicate
        |> fromList
        |> Maybe.withDefault list
