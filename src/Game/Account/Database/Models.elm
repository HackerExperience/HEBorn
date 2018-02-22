module Game.Account.Database.Models exposing (..)

import Dict exposing (Dict)
import Time exposing (Time)
import Game.Meta.Types.Network exposing (NIP)
import Game.Shared exposing (ID)


type alias Model =
    { servers : HackedServers
    , bankAccounts : HackedBankAccounts
    , btcWallets : HackedBitcoinWallets
    , viruses : Viruses
    }


type alias AtmId =
    ID



--Sigma Viruses xD


type alias Viruses =
    Dict ID Virus


type VirusType
    = Spyware
    | Adware
    | BTCMiner


type alias Virus =
    { name : String
    , version : Float
    , type_ : VirusType
    }


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
    { password : String
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
    , virusInstalled : List ID
    , activeVirus : Maybe ID
    , runningTime : Maybe Time
    }


emptyServer : HackedServer
emptyServer =
    { password = ""
    , label = Nothing
    , notes = Nothing
    , virusInstalled = []
    , activeVirus = Nothing
    , runningTime = Nothing
    }


initialModel : Model
initialModel =
    Model Dict.empty Dict.empty Dict.empty Dict.empty


getVirusInstalled : HackedServer -> List ID
getVirusInstalled =
    .virusInstalled


getActiveVirus : HackedServer -> Maybe ID
getActiveVirus =
    .activeVirus


getVirusName : Virus -> String
getVirusName =
    .name


getVirusVersion : Virus -> Float
getVirusVersion =
    .version


getVirusTime : HackedServer -> Maybe Time
getVirusTime =
    .runningTime


getVirus : ID -> Model -> Maybe Virus
getVirus id model =
    Dict.get id model.viruses


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


getHackedServerLabel : HackedServer -> Maybe String
getHackedServerLabel =
    .label


getHackedServer : NIP -> HackedServers -> Maybe HackedServer
getHackedServer nip servers =
    Dict.get nip servers


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


getVirusType : Virus -> VirusType
getVirusType =
    .type_
