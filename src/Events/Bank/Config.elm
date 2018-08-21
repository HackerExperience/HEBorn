module Events.Bank.Config exposing (..)

import Events.Bank.Handlers.Login as BankLogin

type alias Config msg =
    { onBankLogin : BankLogin.Data -> msg
    , onBankLogout : msg
    , onBankAccountUpdated : msg
    , onBankAccountRemoved : msg
    , onBankAccountPasswordRevealed : msg
    }
