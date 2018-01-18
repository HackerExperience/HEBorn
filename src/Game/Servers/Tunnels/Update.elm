module Game.Servers.Tunnels.Update exposing (update)

import Utils.Update as Update
import Core.Dispatch as Dispatch exposing (Dispatch)
import Game.Models as Game
import Game.Servers.Tunnels.Config exposing (..)
import Game.Servers.Tunnels.Messages exposing (..)
import Game.Servers.Tunnels.Models exposing (..)


type alias UpdateResponse msg =
    ( Model, Cmd msg, Dispatch )


update : Config msg -> Msg -> Model -> UpdateResponse msg
update config msg model =
    Update.fromModel model
