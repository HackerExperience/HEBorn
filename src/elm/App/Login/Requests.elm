module App.Login.Requests exposing (..)

import Json.Decode exposing (Decoder, string, decodeString, dict)
import Json.Decode.Pipeline exposing (decode, required, optional)

import Requests.Models exposing (createRequestData
                                , RequestPayloadArgs(RequestUsernamePayload
                                                    , RequestLoginPayload)
                                , Request(NewRequest
                                         , RequestUsername
                                         , RequestLogin)
                                , Response(ResponseUsernameExists
                                          , ResponseLogin
                                          , ResponseInvalid)
                                , ResponseDecoder

                                , ResponseForUsernameExists(..)
                                , ResponseUsernameExistsPayload
                                , ResponseForLogin(..)
                                , ResponseLoginPayload)
import Requests.Update exposing (queueRequest)
import Requests.Decoder exposing (decodeRequest)

import App.Core.Messages as CoreMsg
import App.Core.Models.Core as CoreModel
import App.Login.Messages exposing (Msg(Request))
import App.Login.Models exposing (Model)


type alias ResponseType
    = Response
    -> Model
    -> CoreModel.Model
    -> (Model, Cmd Msg, List CoreMsg.Msg)


-- requestUsernameExists : String -> Cmd Msg
-- requestUsernameExists username =
--     queueRequest (Request
--                       (NewRequest
--                            (createRequestData
--                                 RequestUsername
--                                 decodeUsernameExists
--                                 "account.query"
--                                 (RequestUsernamePayload
--                                      { user = username
--                                      }))))


{-
Request: Sign Up
Description: Create a new account
-}

requestLogin : String -> String -> Cmd Msg
requestLogin username password =
    queueRequest (Request
                      (NewRequest
                           (createRequestData
                                RequestLogin
                                decodeSignUp
                                "account.login"
                                (RequestLoginPayload
                                     { password = password
                                     , username = username
                                     }))))


decodeSignUp : ResponseDecoder
decodeSignUp rawMsg code =
    let
        decoder =
            decode ResponseLoginPayload
                |> required "token" string
    in
        case code of
            200 ->
                case decodeRequest decoder rawMsg of
                    Ok msg ->
                        ResponseLogin (ResponseLoginOk msg.data)

                    Err _ ->
                        ResponseLogin (ResponseLoginInvalid)

            404 ->
                ResponseLogin (ResponseLoginFailed)

            _ ->
                ResponseLogin (ResponseLoginInvalid)


requestLoginHandler : ResponseType
requestLoginHandler response model core =
    case response of
        ResponseLogin (ResponseLoginOk data) ->
            ({model | loginFailed = False}, Cmd.none, [CoreMsg.SetToken (Just data.token)])

        ResponseLogin (ResponseLoginFailed) ->
            ({model | loginFailed = True }, Cmd.none, [])

        ResponseLogin (ResponseLoginInvalid) ->
            ({model | loginFailed = True }, Cmd.none, [])

        _ ->
            (model, Cmd.none, [])

-- Top-level response handler

responseHandler : Request -> ResponseType
responseHandler request data model core =
    case request of

        RequestLogin ->
            requestLoginHandler data model core

        _ ->
            (model, Cmd.none, [])
