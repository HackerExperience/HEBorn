module Apps.SignUp.Requests exposing (..)

import Requests.Models exposing (createRequestData
                                , RequestPayloadArgs(RequestUsernamePayload
                                                    , RequestSignUpPayload)
                                , Request(NewRequest
                                         , RequestUsername
                                         , RequestSignUp)
                                , Response(ResponseUsernameExists
                                          , ResponseSignUp
                                          , ResponseInvalid)
                                , ResponseDecoder

                                , ResponseForUsernameExists(..)
                                , ResponseUsernameExistsPayload
                                , ResponseForSignUp(..)
                                , ResponseSignUpPayload)
import Requests.Update exposing (queueRequest)
import Requests.Decoder exposing (decodeRequest)
import Json.Decode exposing (Decoder, string, decodeString, dict)
import Json.Decode.Pipeline exposing (decode, required, optional)

import Game.Messages exposing (GameMsg)
import Game.Models exposing  (GameModel)
import Apps.SignUp.Messages exposing (Msg(Request))
import Apps.SignUp.Models exposing (Model)


type alias ResponseType
    = Response
    -> Model
    -> GameModel
    -> (Model, Cmd Msg, List GameMsg)


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

requestSignUp : String -> String -> String -> Cmd Msg
requestSignUp email username password =
    queueRequest (Request
                      (NewRequest
                           (createRequestData
                                RequestSignUp
                                decodeSignUp
                                "account.create"
                                (RequestSignUpPayload
                                     { email = email
                                     , password = password
                                     , username = username
                                     }))))


decodeSignUp : ResponseDecoder
decodeSignUp rawMsg code =
    let
        decoder =
            decode ResponseSignUpPayload
                |> required "username" string
                |> required "email" string
                |> required "account_id" string
    in
        case code of
            200 ->
                case decodeRequest decoder rawMsg of
                    Ok msg ->
                        ResponseSignUp (ResponseSignUpOk msg.data)

                    Err _ ->
                        Debug.log "errrr"
                        ResponseSignUp (ResponseSignUpInvalid)

            400 ->
                Debug.log "baaaaaaa"
                ResponseSignUp (ResponseSignUpInvalid)
            _ ->
                Debug.log "code is"
                ResponseSignUp (ResponseSignUpInvalid)

requestSignUpHandler : ResponseType
requestSignUpHandler response model core =
    case response of
        ResponseSignUp (ResponseSignUpOk data) ->
            Debug.log "ok"
            (model, Cmd.none, [])

        ResponseSignUp (ResponseSignUpInvalid) ->
            Debug.log "invalid"
            (model, Cmd.none, [])

        _ ->
            (model, Cmd.none, [])

-- Top-level response handler

responseHandler : Request -> ResponseType
responseHandler request data model core =
    case request of

        RequestSignUp ->
            requestSignUpHandler data model core

        _ ->
            (model, Cmd.none, [])
