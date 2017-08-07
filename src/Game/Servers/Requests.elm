module Game.Servers.Requests exposing (Response(..), receive)

import Game.Servers.Requests.Server as Server
import Game.Servers.Messages exposing (..)


type Response
    = ServerResponse Server.Response


receive : RequestMsg -> Response
receive response =
    case response of
        ServerRequest ( code, data ) ->
            data
                |> Server.receive code
                |> ServerResponse
