module Landing.Login.Requests exposing (Response(..), receive)

import Landing.Login.Messages exposing (..)
import Landing.Login.Requests.Login as Login


type Response
    = LoginResponse Login.Response


receive : RequestMsg -> Maybe Response
receive request =
    case request of
        LoginRequest ( code, json ) ->
            json
                |> Login.receive code
                |> Maybe.map LoginResponse
