module Game.Account.Requests exposing (Response(..), receive)

import Game.Account.Requests.Logout as Logout
import Game.Account.Requests.ServerIndex as ServerIndex
import Game.Account.Messages exposing (..)


type Response
    = LogoutResponse Logout.Response
    | ServerIndexResponse ServerIndex.Response


receive : RequestMsg -> Response
receive response =
    case response of
        LogoutRequestMsg ( code, data ) ->
            data
                |> Logout.receive code
                |> LogoutResponse

        ServerIndexRequestMsg ( code, data ) ->
            data
                |> ServerIndex.receive code
                |> ServerIndexResponse
