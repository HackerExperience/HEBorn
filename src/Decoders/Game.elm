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
import Decoders.Account
import Decoders.Servers
import Decoders.Network


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
        |> account game
        |> hardcoded game.servers
        |> hardcoded game.meta
        |> optional "story" Decoders.Storyline.story Story.initialModel
        |> hardcoded game.web
        |> hardcoded game.config
        |> map (,)
        |> andThen (\done -> map done <| servers)
        |> map (uncurry insertServers)


account : Model -> Decoder (Account.Model -> b) -> Decoder b
account game =
    optional "account" (Decoders.Account.account game.account) game.account


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
        |> required "nips" Decoders.Network.nips
        |> required "endpoints" Decoders.Servers.cids


joinRemote : Decoder ( Servers.CId, Remote )
joinRemote =
    let
        decodeRemote =
            decode Remote
                |> required "network_id" string
                |> required "ip" string
                |> required "password" string
                |> hardcoded Nothing
    in
        decode (,)
            |> custom Decoders.Servers.cid
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
