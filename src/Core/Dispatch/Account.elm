module Core.Dispatch.Account exposing (..)

import Game.Servers.Shared as Servers
import Game.Meta.Types exposing (Context)


{-| Messages related to player's account.
-}
type Dispatch
    = SetGateway Servers.CId
    | SetEndpoint (Maybe Servers.CId)
    | SetContext Context
    | Notify
    | NewGateway Servers.CId
    | PasswordAcquired Servers.CId String
    | LogoutAndCrash ( String, String )
    | Logout
