module Game.Account.Messages exposing (AccountMsg(..))


type AccountMsg
    = Login (Maybe String)
    | Logout
