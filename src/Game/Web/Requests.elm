module Game.Web.Requests exposing (Response(..), receive)

import Game.Web.Messages exposing (..)
import Game.Web.Models exposing (..)
import Game.Web.DNS as DNS
import Game.Web.Requests.DNS as DNS


type Response
    = DNS Requester DNS.Response


receive : RequestMsg -> Maybe Response
receive response =
    case response of
        DNSRequest url requester ( code, data ) ->
            data
                |> DNS.receive url code
                |> Maybe.map (DNS requester)
