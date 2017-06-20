module Landing.SignUp.Requests exposing (Response(..), receive)

import Json.Encode as Encode
import Json.Decode exposing (Value, string, decodeValue, dict, decodeValue)
import Json.Decode.Pipeline exposing (decode, required, optional)
import Landing.SignUp.Messages exposing (..)
import Landing.SignUp.Requests.SignUp as SignUp
import Core.Config exposing (Config)
import Requests.Requests exposing (request, report)
import Requests.Types exposing (Code(..))
import Requests.Topics exposing (Topic(..))


type Response
    = SignUpResponse SignUp.Response


receive : RequestMsg -> Response
receive request =
    case request of
        SignUpRequest ( code, json ) ->
            json
                |> SignUp.receive code
                |> SignUpResponse
