module Setup.Requests exposing (Response(..), receive)

import Setup.Requests.Setup as Setup
import Setup.Messages exposing (..)
import Setup.Models exposing (..)


type Response
    = Setup Setup.Response


receive : RequestMsg -> Maybe Response
receive response =
    case response of
        SetupRequest ( code, data ) ->
            data
                |> Setup.receive code
                |> Maybe.map Setup
