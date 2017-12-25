module Apps.DBAdmin.Resources exposing (..)


type Classes
    = ETop
    | EBottom
    | BtnEdit
    | BtnFilter
    | BtnDelete
    | BtnApply
    | BtnCancel
    | BottomButton
    | BoxifyMe
    | FinanceEntry
    | Bitcoin
    | RealMoney
    | RightSide
    | LeftSide


prefix : String
prefix =
    "udb"
