module Game.Servers.Logs.Dummy exposing (dummy)

import Dict
import Game.Servers.Logs.Models as Logs exposing (..)


dummy : Model
dummy =
    let
        dummy0 =
            ( "dummy0000"
            , new 0 Normal (Just "174.57.204.104 logged in as root")
            )

        dummy1 =
            ( "dummy0001"
            , new 0 Normal (Just "localhost bounced connection from 174.57.204.104 to 209.43.107.189")
            )

        insert_ =
            uncurry insert
    in
        initialModel
            |> insert_ dummy0
            |> insert_ dummy1
