module Landing.Messages exposing (Msg(..))

import Landing.SignUp.Messages as SignUp
import Landing.Login.Messages as Login


type Msg
    = SignUpMsg SignUp.Msg
    | LoginMsg Login.Msg
    | LoadingEnd Int
    | NoOp
