module Game.Account.Notifications.Messages exposing (..)

import Game.Account.Notifications.Shared exposing (..)


type Msg
    = HandleGeneric Title Message
    | HandleNewEmail PersonId
    | HandleReadAll
