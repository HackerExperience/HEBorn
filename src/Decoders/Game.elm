module Decoders.Game exposing (..)

import Dict exposing (Dict)
import Json.Decode as Decode
    exposing
        ( Decoder
        , map
        , andThen
        , oneOf
        , succeed
        , string
        , field
        , list
        )
import Json.Decode.Pipeline exposing (decode, required, hardcoded, optional, custom)
import Game.Account.Models as Account
import Game.Servers.Models as Servers
import Game.Servers.Shared as Servers
import Game.Meta.Types exposing (..)
import Game.Meta.Models as Meta
import Game.Storyline.Models as Story
import Game.Web.Models as Web
import Game.Network.Types as Network exposing (NIP)
import Game.Models exposing (..)
import Utils.Json.Decode exposing (optionalMaybe)
import Decoders.Storyline


type alias ServersToJoin =
    { player : PlayerServers
    , remote : RemoteServers
    }


type alias PlayerServers =
    List Player


type alias RemoteServers =
    Dict Servers.CId Remote


type alias Player =
    { serverId : String
    , nips : List NIP
    , endpoints : List Servers.CId
    }


type alias Remote =
    { networkId : String
    , ip : String
    , password : String
    , bounce : Maybe String
    }


bootstrap : Model -> Decoder ( Model, ServersToJoin )
bootstrap game =
    decode Model
        |> hardcoded game.account
        |> hardcoded game.servers
        |> hardcoded game.meta
        |> optional "story" Decoders.Storyline.story Story.initialModel
        |> hardcoded game.web
        |> hardcoded game.config
        |> map (,)
        |> andThen (\done -> map done <| servers)
        |> map (uncurry insertServers)


servers : Decoder ServersToJoin
servers =
    field "servers" serversToJoin


serversToJoin : Decoder ServersToJoin
serversToJoin =
    decode ServersToJoin
        |> required "player" (list joinPlayer)
        |> required "remote" (map Dict.fromList <| list joinRemote)


joinPlayer : Decoder Player
joinPlayer =
    decode Player
        |> required "server_id" string
        |> required "nips" nips
        |> required "endpoints" cids


joinRemote : Decoder ( Servers.CId, Remote )
joinRemote =
    let
        decodeRemote =
            decode Remote
                |> required "network_id" string
                |> required "ip" string
                |> required "password" string
                |> optionalMaybe "bounce" string
    in
        decode (,)
            |> custom cid
            |> custom decodeRemote


insertServers : Model -> ServersToJoin -> ( Model, ServersToJoin )
insertServers model serversToJoin =
    let
        reducePlayer server servers =
            let
                reduceInsertGateway nip servers =
                    Servers.insertGateway nip
                        server.serverId
                        server.endpoints
                        servers
            in
                List.foldl reduceInsertGateway servers server.nips

        model_ =
            serversToJoin.player
                |> List.foldl reducePlayer (getServers model)
                |> flip setServers model
    in
        ( model_, serversToJoin )


cids : Decoder (List Servers.CId)
cids =
    list cid


cid : Decoder Servers.CId
cid =
    nip


nips : Decoder (List NIP)
nips =
    list nip


nip : Decoder NIP
nip =
    decode Network.toNip
        |> required "network_id" string
        |> required "ip" string
