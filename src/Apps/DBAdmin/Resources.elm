module Apps.DBAdmin.Resources exposing (..)


type Classes
    = ETop
    | EBottom
    | BtnEdit
    | BtnFilter
    | BtnDelete
    | BtnApply
    | BtnCancel
    | BtnBrowse
    | BottomButton
    | BoxifyMe
    | FinanceEntry
    | Bitcoin
    | RealMoney
    | RightSide
    | LeftSide
    | Password


prefix : String
prefix =
    "udb"
