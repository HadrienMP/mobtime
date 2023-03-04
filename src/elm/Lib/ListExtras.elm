module Lib.ListExtras exposing (rotate, uncons, zip)


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


zip : List a -> List b -> List ( a, b )
zip first second =
    zip_ first second []


zip_ : List a -> List b -> List ( a, b ) -> List ( a, b )
zip_ first second acc =
    case ( first, second ) of
        ( [], _ ) ->
            acc

        ( _, [] ) ->
            acc

        ( firstHead :: firstTail, secondHead :: secondTail ) ->
            zip_ firstTail secondTail (acc ++ [ ( firstHead, secondHead ) ])
