module Setup.Requests exposing (Response(..), receive)

import Setup.Requests.Setup as Setup
import Setup.Requests.SetServer as SetServer
import Setup.Messages exposing (..)


type Response
    = SetServer SetServer.Response
    | Setup Setup.Response


receive : RequestMsg -> Maybe Response
receive response =
    case response of
        SetupRequest ( code, data ) ->
            data
                |> Setup.receive code
                |> Maybe.map Setup

        SetServerRequest target ( code, data ) ->
            data
                |> SetServer.receive target code
                |> Maybe.map SetServer
