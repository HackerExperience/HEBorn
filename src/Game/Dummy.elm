module Game.Dummy exposing (dummy)

import Core.Config exposing (Config)
import Game.Models exposing (..)
import Game.Account.Dummy as Account
import Game.Account.Models as Account
import Game.Servers.Dummy as Servers
import Game.Meta.Dummy as Meta


dummy : Account.ID -> Account.Username -> Account.Token -> Config -> Model
dummy id username token config =
    let
        model =
            initialModel id username token config

        account =
            Account.dummy id username token

        servers =
            Servers.dummy

        meta =
            Meta.dummy
    in
        { model
            | account = account
            , servers = servers
            , meta = meta
        }
