module Landing.Login.Requests exposing (..)

import Json.Decode exposing (Decoder, string, decodeString, dict, decodeValue)
import Json.Decode.Pipeline exposing (decode, required, optional)
import Requests.Models
    exposing
        ( createRequestData
        , RequestPayloadArgs
            ( RequestUsernamePayload
            , RequestLoginPayload
            )
        , Request
            ( NewRequest
            , RequestUsername
            , RequestLogin
            )
        , RequestTopic(TopicAccountLogin)
        , emptyTopicContext
        , Response
            ( ResponseUsernameExists
            , ResponseLogin
            , ResponseInvalid
            )
        , ResponseDecoder
        , ResponseCode(..)
        , ResponseForUsernameExists(..)
        , ResponseUsernameExistsPayload
        , ResponseForLogin(..)
        , ResponseLoginPayload
        )
import Requests.Update exposing (queueRequest)
import Requests.Decoder exposing (decodeRequest)
import Core.Messages exposing (CoreMsg)
import Core.Models exposing (CoreModel)
import Core.Dispatcher exposing (callAccount)
import Game.Account.Messages exposing (AccountMsg(Login))
import Landing.Login.Messages exposing (Msg(Request))
import Landing.Login.Models exposing (Model)


type alias ResponseType =
    Response
    -> Model
    -> CoreModel
    -> ( Model, Cmd Msg, List CoreMsg )



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
    queueRequest
        (Request
            (NewRequest
                (createRequestData
                    RequestLogin
                    decodeLogin
                    TopicAccountLogin
                    emptyTopicContext
                    (RequestLoginPayload
                        { password = password
                        , username = username
                        }
                    )
                )
            )
        )


decodeLogin : ResponseDecoder
decodeLogin rawMsg code =
    let
        k =
            Debug.log "<<<" (rawMsg)

        decoder =
            decode ResponseLoginPayload
                |> required "token" string
                |> required "account_id" string
    in
        case code of
            ResponseCodeOk ->
                case decodeValue decoder rawMsg of
                    Ok msg ->
                        ResponseLogin (ResponseLoginOk msg)

                    Err r ->
                        let
                            k =
                                Debug.log ">>>>>>>" (toString r)
                        in
                            ResponseLogin (ResponseLoginInvalid)

            ResponseCodeNotFound ->
                ResponseLogin (ResponseLoginFailed)

            _ ->
                ResponseLogin (ResponseLoginInvalid)


requestLoginHandler : ResponseType
requestLoginHandler response model core =
    case response of
        ResponseLogin (ResponseLoginOk data) ->
            let
                loginCmd =
                    callAccount
                        (Login data)
            in
                ( { model | loginFailed = False }, Cmd.none, [ loginCmd ] )

        ResponseLogin ResponseLoginFailed ->
            ( { model | loginFailed = True }, Cmd.none, [] )

        ResponseLogin ResponseLoginInvalid ->
            ( { model | loginFailed = True }, Cmd.none, [] )

        _ ->
            ( model, Cmd.none, [] )



-- Top-level response handler


responseHandler : Request -> ResponseType
responseHandler request data model core =
    case request of
        RequestLogin ->
            requestLoginHandler data model core

        _ ->
            ( model, Cmd.none, [] )
