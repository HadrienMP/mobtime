module Lib.BatchMsg exposing (UpdateFunction, update)


type alias UpdateFunction msg model =
    msg -> model -> ( model, Cmd msg )


update : List msg -> model -> UpdateFunction msg model -> ( model, Cmd msg )
update msg model updateF =
    update_ msg model [] updateF
        |> Tuple.mapSecond Cmd.batch


update_ : List msg -> model -> List (Cmd msg) -> UpdateFunction msg model -> ( model, List (Cmd msg) )
update_ messages model commandAcc updateF =
    case messages of
        first :: other ->
            let
                ( updated, command ) =
                    updateF first model
            in
            update_ other updated (command :: commandAcc) updateF

        _ ->
            ( model, commandAcc )
