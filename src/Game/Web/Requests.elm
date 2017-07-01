module Game.Web.Requests exposing (Response(..), receive)

import Game.Web.Requests.DNS as DNS
import Game.Web.Messages exposing (..)


type Response
    = DNSResponse DNS.Response


receive : RequestMsg -> Response
receive response =
    case response of
        DNSRequest url ( code, data ) ->
            data
                |> DNS.receive url code
                |> DNSResponse
