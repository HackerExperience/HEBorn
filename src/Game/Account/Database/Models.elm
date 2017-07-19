module Game.Account.Database.Models exposing (..)

import Time exposing (Time)
import Game.Network.Types exposing (NIP)
import Game.Shared exposing (ID)


type ServerType
    = Corporation
    | NPC
    | Player


type alias HackedServer =
    { nip : NIP
    , password : String
    , nick : String
    , notes : Maybe String
    , virusInstalled : List ( ID, String, Float )
    , activeVirus : Maybe ( ID, Time )
    , type_ : ServerType
    , remoteConn : Maybe Never
    }


type alias Database =
    { servers : List HackedServer
    , bankAccounts : List Never
    , wallets : List Never
    }


initialModel : Database
initialModel =
    Database [] [] []
