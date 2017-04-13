module Driver.Http.Http exposing (..)

import Http
import Json.Encode
import Json.Decode exposing (decodeString)
import Requests.Models
    exposing
        ( ResponseCode(..)
        , RequestID
        , getResponseCode
        , invalidRequestId
        )
import Core.Messages exposing (CoreMsg(..))
import Driver.Http.Models exposing (getTopicUrl, getRequestIdHeader)


decodeResult : String -> Json.Encode.Value
decodeResult result =
    case (decodeString Json.Decode.value result) of
        Ok m ->
            m

        Err _ ->
            Json.Encode.null


decodeMsg : RequestID -> Result Http.Error String -> CoreMsg
decodeMsg requestId return =
    case return of
        Ok result ->
            HttpReceivedMessage ( requestId, ResponseCodeOk, decodeResult result )

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
                HttpReceivedMessage ( requestId, code, decodeResult body )

        Err reason ->
            let
                d =
                    Debug.log "FIXME: " (toString reason)
            in
                HttpReceivedMessage
                    ( invalidRequestId
                    , ResponseCodeUnknownError
                    , Json.Encode.null
                    )


send : String -> RequestID -> String -> Cmd CoreMsg
send url id payload =
    Http.send
        (decodeMsg id)
        (Http.request
            { method = "POST"
            , headers =
                [ Http.header "X-Request-Id" id
                ]
            , url = "http://localhost:4000/v1/" ++ url
            , body = Http.stringBody "application/json" payload
            , expect = Http.expectString
            , timeout = Nothing
            , withCredentials = False
            }
        )
