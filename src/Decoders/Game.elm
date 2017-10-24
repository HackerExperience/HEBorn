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
        , maybe
        , fail
        , succeed
        )
import Json.Decode.Pipeline
    exposing
        ( decode
        , required
        , hardcoded
        , optional
        , custom
        , resolve
        )
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
    Dict String Remote


type alias Player =
    { serverId : String
    , nips : List NIP
    , activeNIP : NIP
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
        |> required "storyline" Decoders.Storyline.story
        |> hardcoded game.web
        |> hardcoded game.config
        |> map (,)
        |> andThen (\done -> map done <| servers)
        |> map (uncurry insertServers)


account : Model -> Decoder (Account.Model -> b) -> Decoder b
account game =
    let
        account =
            getAccount game
    in
        optional "account" (Decoders.Account.account account) account


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
        |> andThen playerNetwork
        |> required "endpoints" (list Decoders.Servers.remoteCId)


playerNetwork : (List NIP -> NIP -> a) -> Decoder a
playerNetwork func =
    let
        apply nips maybeNip =
            let
                active =
                    case maybeNip of
                        Just nip ->
                            Just nip

                        Nothing ->
                            nips
                                |> Network.filterInternet
                                |> List.head
            in
                case active of
                    Just nip ->
                        succeed <| func nips nip

                    Nothing ->
                        fail "Couldn't select an active nip for player server"
    in
        decode apply
            |> required "nips" Decoders.Network.nips
            |> custom (maybe Decoders.Network.nip)
            |> resolve


joinRemote : Decoder ( String, Remote )
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
            |> custom (map Servers.toSessionId Decoders.Servers.remoteCId)
            |> custom decodeRemote


insertServers : Model -> ServersToJoin -> ( Model, ServersToJoin )
insertServers model serversToJoin =
    let
        reducePlayer server servers =
            Servers.insertGateway
                server.serverId
                server.activeNIP
                server.nips
                server.endpoints
                servers

        model_ =
            serversToJoin.player
                |> List.foldl reducePlayer (getServers model)
                |> flip setServers model
    in
        ( model_, serversToJoin )
