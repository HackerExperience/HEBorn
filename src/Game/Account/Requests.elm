module Game.Account.Requests exposing (Response(..), receive)

import Game.Account.Requests.ServerIndex as ServerIndex
import Game.Account.Messages exposing (..)


type Response
    = ServerIndexResponse ServerIndex.Response


receive : RequestMsg -> Response
receive response =
    case response of
        ServerIndexRequest ( code, data ) ->
            data
                |> ServerIndex.receive code
                |> ServerIndexResponse

        LogoutRequest _ ->
            Debug.crash "Logout has no response"
