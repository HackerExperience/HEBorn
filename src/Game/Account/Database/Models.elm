module Game.Account.Database.Models exposing (..)

import Game.Shared exposing (ID, IP)


type ServerType
    = Corporation
    | NPC
    | Player


type alias RunningVirus =
    { file : ID
    , task : ID
    }


type alias HackedServer =
    { ip : IP
    , password : String
    , nick : String
    , notes : Maybe String
    , virus : Maybe RunningVirus
    , type_ : ServerType
    , remoteConn : Maybe Never
    }


type alias Database =
    { servers : List HackedServer
    , bankAccounts : List Never
    , wallets : List Never
    }


empty : Database
empty =
    Database [] [] []
