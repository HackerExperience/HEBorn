module Driver.Http.Http exposing (..)

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
import Driver.Http.Models exposing (getTopicUrl, getRequestIdHeader)


decodeMsg : Result Http.Error ( RequestID, String ) -> CoreMsg
decodeMsg result =
    case result of
        Ok ( requestId, result ) ->
            HttpReceivedMessage ( ResponseCodeOk, requestId, result )

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
            , headers =
                [ Http.header "X-Request-Id" id
                ]
            , url = "http://localhost:4000/v1/" ++ url
            , body = Http.stringBody "application/json" payload
            , expect = Http.expectStringResponse (responseWrapper id)
            , timeout = Nothing
            , withCredentials = False
            }
        )


responseWrapper : RequestID -> Http.Response r -> Result error ( RequestID, r )
responseWrapper id response =
    Ok ( id, response.body )
