module Session exposing (..)
import Browser.Navigation as Nav
import Identity
import Url

type alias Session =
    { key : Nav.Key
    , url : Url.Url
    , identity: Identity.Model
    }

updateIdentity : Identity.Model -> Session -> Session
updateIdentity identity session = { session | identity = identity }