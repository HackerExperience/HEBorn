module HttpDriver.Http exposing (..)

import Http
import Json.Decode as Decode exposing (list, string)
import Requests.Models
    exposing
        ( ResponseCode(..)
        , RequestID
        , getResponseCode
        , invalidRequestId
        )
import Core.Messages exposing (CoreMsg(..))
import HttpDriver.Models exposing (getTopicUrl, getRequestIdHeader)


decodeMsg : Result Http.Error ( Maybe RequestID, String ) -> CoreMsg
decodeMsg result =
    case result of
        Ok ( Just requestId, result ) ->
            HttpReceivedMessage ( ResponseCodeOk, requestId, result )

        Ok ( Nothing, result ) ->
            -- TODO: log internal client error
            HttpReceivedMessage
                ( ResponseCodeUnknownError
                , invalidRequestId
                , ""
                )

        Err (Http.BadStatus response) ->
            let
                code =
                    getResponseCode response.status.code

                body =
                    response.body

                requestId =
                    case (getRequestIdHeader response.headers) of
                        Just id ->
                            id

                        Nothing ->
                            invalidRequestId
            in
                HttpReceivedMessage ( code, requestId, body )

        Err reason ->
            let
                d =
                    Debug.log "FIXME: " (toString reason)
            in
                HttpReceivedMessage
                    ( ResponseCodeUnknownError
                    , invalidRequestId
                    , ""
                    )


send : String -> RequestID -> String -> Cmd CoreMsg
send url id payload =
    Http.send
        decodeMsg
        (Http.request
            { method = "POST"
            , headers = [ Http.header "X-Request-ID" id ]
            , url = "http://localhost:4000/v1/" ++ url
            , body = Http.stringBody "application/json" payload
            , expect = Http.expectStringResponse responseExpector
            , timeout = Nothing
            , withCredentials = False
            }
        )


responseExpector : Http.Response r -> Result error ( Maybe String, r )
responseExpector response =
    let
        request_id =
            getRequestIdHeader response.headers
    in
        Ok ( request_id, response.body )
