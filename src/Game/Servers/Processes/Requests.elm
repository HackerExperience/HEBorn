module Game.Servers.Processes.Requests exposing (Response(..), receive)

import Game.Servers.Processes.Requests.Bruteforce as Bruteforce
import Game.Servers.Processes.Requests.Download as Download
import Game.Servers.Processes.Models exposing (..)
import Game.Servers.Processes.Messages exposing (RequestMsg(..))


type Response
    = Bruteforce ID Bruteforce.Response
    | DownloadingFile ID Download.Response


receive : RequestMsg -> Maybe Response
receive response =
    case response of
        BruteforceRequest oldId ( code, data ) ->
            Bruteforce.receive code data
                |> Maybe.map (Bruteforce oldId)

        DownloadRequest oldId ( code, data ) ->
            Download.receive code data
                |> Maybe.map (DownloadingFile oldId)
