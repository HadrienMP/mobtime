module Sse exposing (Event, EventKind, through, decodeData)

import Json.Decode as J

type alias EventKind = String
type alias Event =
    { kind : EventKind
    , data : J.Value
    }

through : (Event -> Result String msg) -> (EventKind, J.Value) -> Result String msg
through dispatchF (kind, data) = dispatchF (Event kind data)

decodeData : J.Decoder a -> Event -> Result String a
decodeData decoder event =
    J.decodeValue decoder event.data
    |> Result.mapError J.errorToString