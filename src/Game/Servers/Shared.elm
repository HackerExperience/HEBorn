module Game.Servers.Shared exposing (..)

import Game.Meta.Types.Network exposing (NIP)


type alias Id =
    String


type alias EndpointAddress =
    NIP


type CId
    = GatewayCId Id
    | EndpointCId EndpointAddress


type alias StorageId =
    String


type alias SessionId =
    String
