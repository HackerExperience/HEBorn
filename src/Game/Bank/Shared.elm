module Game.Bank.Shared exposing (..)


type alias BankAccountData =
    { balance : Int
    }


type ChangePassError
    = CPBankAccountNotBelongs
    | CPBadRequest


type CloseAccountError
    = ClAccBankAccountNotBelongs
    | ClAccBankAccountNotEmpty
    | ClAccBadRequest


type CreateAccountError
    = CrAccBadRequest
    | CrAccServerNotBelongs


type RevealPasswordError
    = RPBadRequest
    | RPTokenInvalid
    | RPTokenExpired


type TransferError
    = TFBadRequest
    | TFNotABank
    | TFNotEnoughFunds
    | TFAccountNotExists


type LogoutError
    = LOBadRequest


toMoney : Int -> String
toMoney value =
    let
        str =
            toString value

        ( dolars, cents ) =
            ( String.dropRight 2 str, String.right 2 str )

        formatedStr =
            if String.length dolars > 0 then
                dolars ++ "." ++ cents
            else
                "0." ++ cents
    in
        formatedStr
