module Driver.Http.Http exposing (send)

import Http


send :
    (Result Http.Error String -> msg)
    -> String
    -> String
    -> String
    -> Cmd msg
send msg apiHttpUrl path payload =
    Http.send
        msg
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
