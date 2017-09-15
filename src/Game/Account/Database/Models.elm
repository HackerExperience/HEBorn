module Game.Account.Database.Models exposing (..)

import Dict exposing (Dict)
import Time exposing (Time)
import Game.Network.Types exposing (NIP)
import Game.Shared exposing (ID)


type alias Model =
    { servers : HackedServers
    , bankAccounts : List String
    , btcWallets : List String
    }


type ServerType
    = Corporation
    | NPC
    | Player


type alias InstalledVirus =
    ( ID, String, Float )


type alias RunningVirus =
    ( ID, Time )


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
    Model Dict.empty [] []


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
