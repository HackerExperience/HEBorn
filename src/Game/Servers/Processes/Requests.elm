module Game.Servers.Processes.Requests exposing (Response(..), receive)

import Game.Servers.Processes.Requests.Bruteforce as Bruteforce
import Game.Servers.Processes.Messages exposing (RequestMsg(..))


type Response
    = Bruteforce Bruteforce.Response


receive : RequestMsg -> Maybe Response
receive response =
    case response of
        BruteforceRequest optimistic ( code, data ) ->
            Maybe.map Bruteforce <| Bruteforce.receive optimistic code data
