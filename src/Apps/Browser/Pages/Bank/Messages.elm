module Apps.Browser.Pages.Bank.Messages exposing (Msg(..))


type Msg
    = HandleLogin String
    | HandleLoginError
    | SetTransfer
    | HandleTransferError
    | SetLoading
    | Logout
    | UpdateLoginField String
    | UpdatePasswordField String
    | UpdateTransferBankField String
    | UpdateTransferAccountField String
    | UpdateTransferValueField String
