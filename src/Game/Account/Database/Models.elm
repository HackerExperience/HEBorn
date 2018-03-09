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
    , extension : String
    , runningTime : Maybe Time
    , isActive : Bool
    }


type alias HackedBankAccount =
    { name : String
    , password : Maybe String
    , knownBalance : Maybe Int
    , token : Maybe String
    , notes : Maybe String
    , lastLoginDate : Maybe Time
    , lastUpdate : Time
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
    , alias : Maybe String
    , notes : Maybe String
    , virusInstalled : Viruses
    }


emptyServer : HackedServer
emptyServer =
    { password = ""
    , alias = Nothing
    , notes = Nothing
    , virusInstalled = Dict.empty
    }


initialModel : Model
initialModel =
    Model Dict.empty Dict.empty Dict.empty


getVirusInstalled : HackedServer -> Viruses
getVirusInstalled =
    .virusInstalled


getActiveVirus : HackedServer -> Maybe Virus
getActiveVirus server =
    server.virusInstalled
        |> Dict.filter (\_ v -> v.isActive)
        |> Dict.values
        |> List.head


getVirusName : Virus -> String
getVirusName =
    .name


getVirusVersion : Virus -> Float
getVirusVersion =
    .version


getVirusTime : HackedServer -> Maybe Time
getVirusTime server =
    Maybe.andThen .runningTime (getActiveVirus server)


getVirus : ID -> HackedServer -> Maybe Virus
getVirus id server =
    Dict.get id server.virusInstalled


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


getHackedServerAlias : HackedServer -> Maybe String
getHackedServerAlias =
    .alias


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
