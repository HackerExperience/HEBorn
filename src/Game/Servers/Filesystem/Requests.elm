module Game.Servers.Filesystem.Requests
    exposing
        ( Response(..)
        , receive
        )

import Game.Servers.Filesystem.Requests.Index as Index
import Game.Servers.Filesystem.Messages exposing (..)


type Response
    = Index Index.Response


receive : RequestMsg -> Maybe Response
receive response =
    case response of
        IndexRequest ( code, data ) ->
            data
                |> Index.receive code
                |> Maybe.map Index

        _ ->
            Nothing
