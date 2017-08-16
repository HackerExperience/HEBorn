module Game.Web.Requests exposing (Response(..), receive)

import Game.Web.Requests.DNS as DNS
import Game.Web.Messages exposing (..)


type Response
    = DNS DNS.Response


receive : RequestMsg -> Maybe Response
receive response =
    case response of
        DNSRequest url ( code, data ) ->
            data
                |> DNS.receive url code
                |> Maybe.map DNS
