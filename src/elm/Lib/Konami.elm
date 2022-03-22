module Lib.Konami exposing (Konami, add, empty, isActivated)


type Konami
    = Konami (List String)


empty : Konami
empty =
    Konami []


asList : Konami -> List String
asList konami =
    case konami of
        Konami keys ->
            keys


add : String -> Konami -> Konami
add key konami =
    let
        keys =
            asList konami
    in
    key :: keys
    |> List.take 10
    |> Konami


isActivated : Konami -> Bool
isActivated konami =
    List.reverse [ "ArrowUp", "ArrowUp", "ArrowDown", "ArrowDown", "ArrowLeft", "ArrowRight", "ArrowLeft", "ArrowRight", "a", "b" ] == asList konami
