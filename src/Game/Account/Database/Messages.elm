module Game.Account.Database.Messages exposing (Msg(..))

import Events.Account.PasswordAcquired as PasswordAcquired


type Msg
    = HandlePasswordAcquired PasswordAcquired.Data
