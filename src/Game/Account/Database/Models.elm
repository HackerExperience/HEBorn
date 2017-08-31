module Game.Account.Database.Models exposing (..)

import Dict exposing (Dict)
import Time exposing (Time)
import Game.Network.Types exposing (NIP)
import Game.Shared exposing (ID)


type ServerType
    = Corporation
    | NPC
    | Player


type alias InstalledVirus =
    ( ID, String, Float )


type alias RunningVirus =
    ( ID, Time )


type alias HackedServer =
    { password : String
    , label : Maybe String
    , notes : Maybe String
    , virusInstalled : List InstalledVirus
    , activeVirus : Maybe RunningVirus
    , type_ : ServerType
    , remoteConn : Maybe String
    }


type alias HackedServers =
    Dict NIP HackedServer


type alias Database =
    { servers : HackedServers
    , bankAccounts : List String
    , btcWallets : List String
    }


initialModel : Database
initialModel =
    Database Dict.empty [] []
