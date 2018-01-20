module Game.Servers.Tunnels.Update exposing (update)

import Game.Servers.Tunnels.Config exposing (..)
import Game.Servers.Tunnels.Messages exposing (..)
import Game.Servers.Tunnels.Models exposing (..)


type alias UpdateResponse msg =
    ( Model, Cmd msg )


update : Config msg -> Msg -> Model -> UpdateResponse msg
update config msg model =
    ( model, Cmd.none )
