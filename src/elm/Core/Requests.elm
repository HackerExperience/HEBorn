module Core.Requests exposing (..)

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

import Core.Messages exposing (CoreMsg(Request))
import Core.Models exposing (CoreModel)


type alias ResponseType
    = Response
    -> CoreModel
    -> (CoreModel, Cmd CoreMsg)


requestLogout : String -> Cmd CoreMsg
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
