module Game.Requests exposing (Response(..), receive)

import Game.Requests.Resync as Resync
import Game.Messages exposing (..)
import Game.Models exposing (..)


type Response
    = Resync Resync.Response


receive : Model -> RequestMsg -> Maybe Response
receive model response =
    case response of
        ResyncRequest ( code, data ) ->
            data
                |> Resync.receive model code
                |> Maybe.map Resync
