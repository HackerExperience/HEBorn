module Landing.Login.Requests exposing (Response(..), receive)

import Landing.Login.Messages exposing (..)
import Landing.Login.Requests.Login as Login


type Response
    = LoginResponse Login.Response


receive : RequestMsg -> Response
receive request =
    case request of
        LoginRequestMsg ( code, json ) ->
            json
                |> Login.receive code
                |> LoginResponse
