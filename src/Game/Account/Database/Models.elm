module Game.Account.Database.Models exposing (..)

import Dict exposing (Dict)
import Time exposing (Time)
import Game.Meta.Types.Network exposing (NIP)
import Game.Shared exposing (ID)


type alias Model =
    { servers : HackedServers
    , bankAccounts : HackedBankAccounts
    , btcWallets : HackedBitcoinWallets
    }


type ServerType
    = Corporation
    | NPC
    | Player


type alias AtmId =
    ID


type alias InstalledVirus =
    ( ID, String, Float )


type alias RunningVirus =
    ( ID, Time )


type alias HackedBankAccount =
    { name : String
    , password : String
    , balance : Int
    }


type alias HackedAccountNumber =
    Int


type alias HackedBankAccountID =
    ( AtmId, HackedAccountNumber )


type alias HackedBankAccounts =
    Dict HackedBankAccountID HackedBankAccount


type alias HackedBitcoinAddress =
    String


type alias HackedBitcoinWallet =
    { address : String
    , password : String
    , balance : Float
    }


type alias HackedBitcoinWallets =
    Dict HackedBitcoinAddress HackedBitcoinWallet


type alias HackedServers =
    Dict NIP HackedServer


type alias HackedServer =
    { password : String
    , label : Maybe String
    , notes : Maybe String
    , virusInstalled : List InstalledVirus
    , activeVirus : Maybe RunningVirus
    , type_ : ServerType
    , remoteConn : Maybe String
    }


initialModel : Model
initialModel =
    Model Dict.empty Dict.empty Dict.empty


getHackedServers : Model -> HackedServers
getHackedServers =
    .servers


setHackedServers : HackedServers -> Model -> Model
setHackedServers servers model =
    { model | servers = servers }


getPassword : HackedServer -> String
getPassword =
    .password


setPassword : String -> HackedServer -> HackedServer
setPassword password server =
    { server | password = password }


{-| Returns a new HackedServer if no one is found.
-}
getHackedServer : NIP -> HackedServers -> HackedServer
getHackedServer nip servers =
    case Dict.get nip servers of
        Just server ->
            server

        Nothing ->
            { password = ""
            , label = Nothing
            , notes = Nothing
            , virusInstalled = []
            , activeVirus = Nothing
            , type_ = NPC
            , remoteConn = Nothing
            }


insertServer : NIP -> HackedServer -> HackedServers -> HackedServers
insertServer =
    Dict.insert


insertBankAccount :
    HackedBankAccountID
    -> HackedBankAccount
    -> HackedBankAccounts
    -> HackedBankAccounts
insertBankAccount id account hackedAccounts =
    Dict.insert id account hackedAccounts


removeBankAccount :
    HackedBankAccountID
    -> HackedBankAccounts
    -> HackedBankAccounts
removeBankAccount id hackedAccounts =
    Dict.remove id hackedAccounts


insertBitcoinWallet :
    HackedBitcoinAddress
    -> HackedBitcoinWallet
    -> HackedBitcoinWallets
    -> HackedBitcoinWallets
insertBitcoinWallet address wallet hackedWallets =
    Dict.insert address wallet hackedWallets


getBankAccounts : Model -> HackedBankAccounts
getBankAccounts =
    .bankAccounts


getBitcoinWallets : Model -> HackedBitcoinWallets
getBitcoinWallets =
    .btcWallets
