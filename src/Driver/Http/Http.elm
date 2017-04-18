module Driver.Http.Http exposing (..)

import Http
import Json.Encode
import Json.Decode exposing (decodeString)
import Driver.Http.Models exposing (getRequestIdHeader)
import Requests.Models
    exposing
        ( ResponseCode(..)
        , RequestID
        , getResponseCode
        , invalidRequestId
        )
import Core.Messages exposing (CoreMsg(NewResponse))


stringToValue : String -> Json.Encode.Value
stringToValue result =
    case (decodeString Json.Decode.value result) of
        Ok m ->
            m

        Err _ ->
            Json.Encode.null


decodeMsg : RequestID -> Result Http.Error String -> CoreMsg
decodeMsg requestId return =
    case return of
        Ok result ->
            NewResponse ( requestId, ResponseCodeOk, stringToValue result )

        Err (Http.BadStatus response) ->
            let
                code =
                    getResponseCode response.status.code

                body =
                    response.body
            in
                NewResponse ( requestId, code, stringToValue body )

        Err reason ->
            let
                d =
                    Debug.log "FIXME: " (toString reason)
            in
                NewResponse
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
            , headers = []
            , url = "http://localhost:4000/v1/" ++ url
            , body = Http.stringBody "application/json" payload
            , expect = Http.expectString
            , timeout = Nothing
            , withCredentials = False
            }
        )
