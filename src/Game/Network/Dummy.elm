module Game.Network.Dummy exposing (dummy)

import Game.Network.Models exposing (..)


dummy : Model
dummy =
    let
        model =
            initialModel

        tunnel1 =
            newTunnel "192.168.0.16" "153.249.31.179" model

        tunnel2 =
            newTunnel "192.168.0.16" "153.249.31.179" model

        bounce1 =
            { name = "Soon I'm gonna be a Jedi"
            , chain =
                [ "42.23.13.4"
                , "tedmosbyisnotajerk.com"
                , "notafathersday.com"
                , "grademyteacher.net"
                , "barneysvideoresume.com"
                , "8.8.4.4"
                ]
            }
    in
        model
            |> insertTunnel "tunnel1" tunnel1
            |> insertTunnel "tunnel2" tunnel2
            |> setActiveTunnel (Just "tunnel1")
            |> setBounce "bounce1" (Just bounce1)
