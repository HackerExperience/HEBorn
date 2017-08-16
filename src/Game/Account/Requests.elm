module Game.Account.Requests exposing (Response(..), receive)

import Game.Account.Messages exposing (..)


type Response
    = Logout


receive : RequestMsg -> Maybe Response
receive response =
    case response of
        LogoutRequest _ ->
            Just Logout
