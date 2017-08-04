module Game.Requests exposing (Response(..), receive)

import Game.Requests.Bootstrap as Bootstrap
import Game.Messages exposing (..)


type Response
    = BootstrapResponse Bootstrap.Response


receive : RequestMsg -> Response
receive response =
    case response of
        BootstrapRequest ( code, data ) ->
            data
                |> Bootstrap.receive code
                |> BootstrapResponse
