module Lib.ListExtras exposing (..)

rotate : List a -> List a
rotate list =
    uncons list
        |> Tuple.mapFirst (Maybe.map List.singleton >> Maybe.withDefault [])
        |> (\( head, tail ) -> tail ++ head)


uncons : List a -> ( Maybe a, List a )
uncons list =
    ( list, list )
        |> Tuple.mapBoth List.head List.tail
        |> Tuple.mapSecond (Maybe.withDefault [])
