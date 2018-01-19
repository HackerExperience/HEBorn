module Game.Dummy exposing (dummy)

import Core.Flags exposing (Flags)
import Game.Models exposing (..)
import Game.Account.Models as Account
import Game.Servers.Models as Servers
import Game.Meta.Dummy as Meta


dummy : Account.ID -> Account.Username -> Account.Token -> Flags -> Model
dummy id username token flags =
    let
        model =
            initialModel id username token flags

        account =
            Account.initialModel id username token

        servers =
            Servers.initialModel

        meta =
            Meta.dummy
    in
        { model
            | account = account
            , servers = servers
            , meta = meta
        }
