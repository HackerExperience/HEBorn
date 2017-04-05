module Game.Requests exposing (responseHandler)


import Requests.Models exposing ( Request(NewRequest
                                         , RequestLogout)
                                , Response)

import Game.Messages exposing (GameMsg)
import Game.Models exposing (ResponseType)
import Game.Account.Requests exposing (requestLogoutHandler)


-- Top-level response handler

responseHandler : Request -> ResponseType
responseHandler request data model =
    case request of

        RequestLogout ->
            requestLogoutHandler data model

        _ ->
            (model, Cmd.none, [])
