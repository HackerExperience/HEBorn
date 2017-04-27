module Driver.Http.Http exposing (..)

import Http
import Driver.Http.Models exposing (decodeMsg)
import Requests.Models exposing (RequestID)
import Core.Messages exposing (CoreMsg)


send : String -> String -> RequestID -> String -> Cmd CoreMsg
send apiHttpUrl path id payload =
    Http.send
        (decodeMsg id)
        (Http.request
            { method = "POST"
            , headers = []
            , url = apiHttpUrl ++ "/" ++ path
            , body = Http.stringBody "application/json" payload
            , expect = Http.expectString
            , timeout = Nothing
            , withCredentials = False
            }
        )
