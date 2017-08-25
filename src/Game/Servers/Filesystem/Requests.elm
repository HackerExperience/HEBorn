module Game.Servers.Filesystem.Requests
    exposing
        ( Response(..)
        , receive
        )

import Game.Servers.Filesystem.Messages exposing (..)


type Response
    = Dummy


receive : RequestMsg -> Maybe Response
receive response =
    case response of
        _ ->
            Nothing
