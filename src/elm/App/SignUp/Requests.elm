module App.SignUp.Requests exposing (..)

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
import App.SignUp.Messages exposing (Msg(Request))
import App.SignUp.Models exposing (Model)
import Json.Decode exposing (Decoder, string, decodeString, dict)
import Json.Decode.Pipeline exposing (decode, required, optional)


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

requestSignUp : String -> String -> Cmd Msg
requestSignUp email password =
    queueRequest (Request
                      (NewRequest
                           (createRequestData
                                RequestSignUp
                                decodeSignUp
                                "account.create"
                                (RequestSignUpPayload
                                     { email = email
                                     , password = password
                                     , password_confirmation = password
                                     }))))


decodeSignUp : ResponseDecoder
decodeSignUp rawMsg code =
    let
        decoder =
            decode ResponseSignUpPayload
                |> required "user" string
    in
        case code of
            200 ->
                case decodeRequest decoder rawMsg of
                    Ok msg ->
                        ResponseSignUp (ResponseSignUpOk msg.data)

                    Err _ ->
                        ResponseSignUp (ResponseSignUpInvalid)

            _ ->
                ResponseSignUp (ResponseSignUpInvalid)


requestSignUpHandler : Response -> Model -> (Model, Cmd Msg)
requestSignUpHandler response model =
    case response of
        ResponseSignUp (ResponseSignUpOk data) ->
            (model, Cmd.none)

        ResponseSignUp (ResponseSignUpInvalid) ->
            (model, Cmd.none)

        _ ->
            (model, Cmd.none)

-- Top-level response handler

responseHandler : Request -> Response -> Model -> (Model, Cmd Msg)
responseHandler request data model =
    case request of

        RequestSignUp ->
            requestSignUpHandler data model

        _ ->
            (model, Cmd.none)
