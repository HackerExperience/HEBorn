module Game.Account.Database.Models exposing (..)

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
    { nip : NIP
    , password : String
    , label : Maybe String
    , notes : Maybe String
    , virusInstalled : List InstalledVirus
    , activeVirus : Maybe RunningVirus
    , type_ : ServerType
    , remoteConn : Maybe String
    }


type alias Database =
    { servers : List HackedServer
    , bankAccounts : List String
    , btcWallets : List String
    }


initialModel : Database
initialModel =
    Database [] [] []
