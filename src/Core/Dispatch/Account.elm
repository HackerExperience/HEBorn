module Core.Dispatch.Account exposing (..)

{-| Messages related to player's account.
-}


type Dispatch
    = SetGateway
    | SetSession
    | PasswordAcquired
