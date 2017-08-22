module Game.Servers.Web.Requests exposing (Response(..), receive)

import Game.Servers.Web.Requests.DNS as DNS
import Game.Servers.Web.Messages exposing (..)


type Response
    = DNS DNS.Response


receive : RequestMsg -> Maybe Response
receive response =
    case response of
        DNSRequest url ( code, data ) ->
            data
                |> DNS.receive url code
                |> Maybe.map DNS
