module Landing.SignUp.Requests exposing (Response(..), receive)

import Landing.SignUp.Messages exposing (..)
import Landing.SignUp.Requests.SignUp as SignUp


type Response
    = SignUpResponse SignUp.Response


receive : RequestMsg -> Response
receive request =
    case request of
        SignUpRequestMsg ( code, json ) ->
            json
                |> SignUp.receive code
                |> SignUpResponse
