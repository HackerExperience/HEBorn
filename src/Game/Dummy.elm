module Game.Dummy exposing (dummy)

import Core.Config exposing (Config)
import Game.Models exposing (..)
import Game.Account.Dummy as Account
import Game.Servers.Dummy as Servers
import Game.Meta.Dummy as Meta


dummy : String -> Config -> Model
dummy token config =
    let
        model =
            initialModel token config

        account =
            Account.dummy token

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
