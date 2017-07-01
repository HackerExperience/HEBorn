module Game.Account.Database.Models exposing (..)

import Time exposing (Time)
import Game.Shared exposing (ID, IP)


type ServerType
    = Corporation
    | NPC
    | Player


type alias HackedServer =
    { ip : IP
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
