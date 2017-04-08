module Game.Account.Requests exposing (..)

import Requests.Models
    exposing
        ( createRequestData
        , RequestPayloadArgs(RequestLogoutPayload)
        , Request
            ( NewRequest
            , RequestLogout
            )
        , Response(ResponseLogout)
        , ResponseDecoder
        , ResponseForLogout(..)
        )
import Requests.Update exposing (queueRequest)
import Game.Messages exposing (GameMsg(Request))
import Game.Models exposing (GameModel, ResponseType)


requestLogout : String -> Cmd GameMsg
requestLogout token =
    queueRequest
        (Request
            (NewRequest
                (createRequestData
                    RequestLogout
                    decodeLogout
                    "account.logout"
                    (RequestLogoutPayload
                        { token = token
                        }
                    )
                )
            )
        )


decodeLogout : ResponseDecoder
decodeLogout rawMsg code =
    case code of
        _ ->
            ResponseLogout (ResponseLogoutOk)


requestLogoutHandler : ResponseType
requestLogoutHandler response model =
    case response of
        _ ->
            ( model, Cmd.none, [] )
