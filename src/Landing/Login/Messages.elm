module Landing.Login.Messages exposing (..)

import Landing.Requests.Login as Login


type Msg
    = SubmitLogin
    | SetUsername String
    | SetPassword String
    | LoginRequest Login.Data
