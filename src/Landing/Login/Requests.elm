module Landing.Login.Requests exposing (Response(..), receive)

import Json.Encode as Encode
import Json.Decode exposing (Value, string, decodeValue, dict, decodeValue)
import Json.Decode.Pipeline exposing (decode, required, optional)
import Landing.Login.Messages exposing (..)
import Landing.Login.Requests.Login as Login
import Requests.Requests exposing (request, report)
import Requests.Topics exposing (Topic(..))
import Requests.Types exposing (Code(..))


type Response
    = LoginResponse Login.Response


receive : RequestMsg -> Response
receive request =
    case request of
        LoginRequest ( code, json ) ->
            json
                |> Login.receive code
                |> LoginResponse
