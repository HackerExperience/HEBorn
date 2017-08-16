module Game.Requests exposing (Response(..), receive)

import Game.Requests.Bootstrap as Bootstrap
import Game.Messages exposing (..)


type Response
    = Bootstrap Bootstrap.Response


receive : RequestMsg -> Maybe Response
receive response =
    case response of
        BootstrapRequest ( code, data ) ->
            data
                |> Bootstrap.receive code
                |> Maybe.map Bootstrap
