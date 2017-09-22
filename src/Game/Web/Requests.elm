module Game.Web.Requests exposing (Response(..), receive)

import Game.Web.Messages exposing (..)
import Game.Web.Models as Web
import Game.Web.Requests.DNS as DNS


type Response
    = DNS Web.Requester Web.Response


receive : RequestMsg -> Maybe Response
receive response =
    case response of
        DNSRequest url requester ( code, data ) ->
            data
                |> DNS.receive url code
                |> Maybe.map (DNS requester)
