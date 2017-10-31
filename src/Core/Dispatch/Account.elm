module Core.Dispatch.Account exposing (..)

import Game.Servers.Shared as Servers
import Game.Meta.Types exposing (Context)
import Events.Account.PasswordAcquired as PasswordAcquired


{-| Messages related to player's account.
-}
type Dispatch
    = SetGateway Servers.CId
    | SetEndpoint (Maybe Servers.CId)
    | SetContext Context
    | Notify
    | NewGateway Servers.CId
    | PasswordAcquired PasswordAcquired.Data
    | LogoutAndCrash ( String, String )
    | Logout
