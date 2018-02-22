module Game.Account.Finances.Dummy exposing (..)

import Dict
import Game.Account.Finances.Models exposing (..)


dummy : Model
dummy =
    Model bankAccountsDummy Dict.empty


bankAccountsDummy : BankAccounts
bankAccountsDummy =
    Dict.empty
        |> Dict.insert ( "bank", 697887 ) bankAccount
        |> Dict.insert ( "bank", 809809 ) bankAccount
        |> Dict.insert ( "bank", 736559 ) bankAccount
        |> Dict.insert ( "bank", 658037 ) bankAccount
        |> Dict.insert ( "bank", 300707 ) bankAccount
        |> Dict.insert ( "bank", 614331 ) bankAccount


bankAccount : BankAccount
bankAccount =
    { name = "Bank de Jesus"
    , password = "senhadobanco"
    , balance = 60000
    }
