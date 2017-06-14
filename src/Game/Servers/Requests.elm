module Game.Servers.Requests exposing (Response(..), receive)

import Game.Servers.Requests.LogIndex as LogIndex
import Game.Servers.Requests.FileIndex as FileIndex
import Game.Servers.Messages exposing (..)


type Response
    = LogIndexResponse LogIndex.Response
    | FileIndexResponse FileIndex.Response


receive : RequestMsg -> Response
receive response =
    case response of
        LogIndexRequest ( code, data ) ->
            data
                |> LogIndex.receive code
                |> LogIndexResponse

        FileIndexRequest ( code, data ) ->
            data
                |> FileIndex.receive code
                |> FileIndexResponse
