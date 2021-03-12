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



assign : List a -> List b -> List ( Maybe a, Maybe b )
assign first second =
    assign_ first second []


assign_ : List a -> List b -> List ( Maybe a, Maybe b ) -> List ( Maybe a, Maybe b )
assign_ first second acc =
    case ( first, second ) of
        ( [], [] ) ->
            acc

        _ ->
            let
                (firstHead, firstTail) = uncons first
                (secondHead, secondTail) = uncons second
            in
            assign_ firstTail secondTail (acc ++ [ ( firstHead, secondHead ) ])
