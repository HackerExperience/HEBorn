module Game.Account.Database.Dummy exposing (dummy)

import Dict as Dict
import Random as Random
import Game.Account.Database.Models exposing (..)


dummy : Model
dummy =
    Model servers bankAccounts btcWallets viruses


servers : HackedServers
servers =
    let
        installed =
            [ "Virus1"
            , "Virus2"
            , "Virus3"
            , "Virus4"
            ]
    in
        Dict.empty
            |> Dict.insert ( "::1", "123.426.988.546" )
                (server "Virus1" installed 65.150006)
            |> Dict.insert ( "::1", "133.234.253.333" )
                (server "Virus2" installed 1.3523353)
            |> Dict.insert ( "::1", "356.534.233.423" )
                (server "Virus3" installed 3352.3343)
            |> Dict.insert ( "::1", "666.264.543.244" )
                (server "Virus4" installed 122.33333)


bankAccounts : HackedBankAccounts
bankAccounts =
    Dict.empty
        |> Dict.insert ( "bank", 999999 ) bankAccount
        |> Dict.insert ( "bank", 123456 ) bankAccount
        |> Dict.insert ( "bank", 321456 ) bankAccount
        |> Dict.insert ( "bank", 651852 ) bankAccount
        |> Dict.insert ( "bank", 561200 ) bankAccount
        |> Dict.insert ( "bank", 101257 ) bankAccount


btcWallets : HackedBitcoinWallets
btcWallets =
    Dict.empty
        |> Dict.insert "address1" wallet
        |> Dict.insert "address2" wallet
        |> Dict.insert "address3" wallet
        |> Dict.insert "address4" wallet
        |> Dict.insert "address5" wallet
        |> Dict.insert "address6" wallet
        |> Dict.insert "address7" wallet
        |> Dict.insert "address8" wallet
        |> Dict.insert "address9" wallet
        |> Dict.insert "address10" wallet


viruses : Viruses
viruses =
    Dict.empty
        |> Dict.insert "Virus1" spyware
        |> Dict.insert "Virus2" adware
        |> Dict.insert "Virus3" spyware
        |> Dict.insert "Virus4" btcMiner


server : String -> List String -> Float -> HackedServer
server virusId installed time =
    let
        emptyS =
            emptyServer

        server_ =
            { emptyS
                | password = "senhadoserver"
                , virusInstalled = installed
                , activeVirus = Just virusId
                , runningTime = Just time
            }
    in
        server_


bankAccount : HackedBankAccount
bankAccount =
    { name = "Bank de Jesus"
    , password = "senhadobanco"
    , balance = 60000
    }


wallet : HackedBitcoinWallet
wallet =
    { password = "senhadawallet"
    , balance = 1655465.16516555
    }


virus : String -> VirusType -> Virus
virus name type_ =
    { name = name
    , version = 1.6516515
    , type_ = type_
    }


spyware : Virus
spyware =
    virus "Windows" Spyware


adware : Virus
adware =
    virus "Hao123" Adware


btcMiner : Virus
btcMiner =
    virus "the_pirate_bay" BTCMiner
