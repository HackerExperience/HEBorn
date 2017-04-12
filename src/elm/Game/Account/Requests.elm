module Game.Account.Requests exposing (..)

import Json.Decode exposing (Decoder, string, decodeString, dict)
import Json.Decode.Pipeline exposing (decode, required, optional)
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


lol =
    5



-- requestLogout : String -> Cmd GameMsg
-- requestLogout token =
--     queueRequest
--         (Request
--             (NewRequest
--                 (createRequestData
--                     RequestLogout
--                     decodeLogout
--                     rawDecodeLogout
--                     "account.logout"
--                     (RequestLogoutPayload
--                         { token = token
--                         }
--                     )
--                 )
--             )
--         )
-- rawDecodeLogout =
--     decode RequestLogoutPayload
--         |> required "token" string
-- decodeLogout : ResponseDecoder
-- decodeLogout rawMsg code =
--     case code of
--         _ ->
--             ResponseLogout (ResponseLogoutOk)
-- requestLogoutHandler : ResponseType
-- requestLogoutHandler response model =
--     case response of
--         _ ->
--             ( model, Cmd.none, [] )
