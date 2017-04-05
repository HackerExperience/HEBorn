module Game.Requests exposing (..)

-- import Json.Decode exposing (Decoder, string, decodeString, dict)
-- import Json.Decode.Pipeline exposing (decode, required, optional)

import Requests.Models exposing (createRequestData
                                , RequestPayloadArgs(RequestLogoutPayload)
                                , Request(NewRequest
                                         , RequestLogout)
                                , Response(ResponseLogout)
                                , ResponseDecoder

                                , ResponseForLogout(..))
import Requests.Update exposing (queueRequest)
-- import Requests.Decoder exposing (decodeRequest)

import Game.Messages exposing (GameMsg(Request))
import Game.Models exposing (GameModel)


type alias ResponseType
    = Response
    -> GameModel
    -> (GameModel, Cmd GameMsg)


requestLogout : String -> Cmd GameMsg
requestLogout token =
    queueRequest (Request
                      (NewRequest
                           (createRequestData
                                RequestLogout
                                decodeLogout
                                "account.logout"
                                (RequestLogoutPayload
                                     { token = token
                                     }))))


decodeLogout : ResponseDecoder
decodeLogout rawMsg code =
    case code of
        _ ->
            ResponseLogout (ResponseLogoutOk)


requestLogoutHandler : ResponseType
requestLogoutHandler response model =
    case response of
        _ ->
            (model, Cmd.none)

-- Top-level response handler

responseHandler : Request -> ResponseType
responseHandler request data model =
    case request of

        RequestLogout ->
            requestLogoutHandler data model

        _ ->
            (model, Cmd.none)
