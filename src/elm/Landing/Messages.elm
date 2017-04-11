module Landing.Messages exposing (LandMsg(..))

import Landing.SignUp.Messages
import Landing.Login.Messages


type LandMsg
    = MsgSignUp Landing.SignUp.Messages.Msg
    | MsgLogin Landing.Login.Messages.Msg
