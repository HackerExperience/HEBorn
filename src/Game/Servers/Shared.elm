module Game.Servers.Shared exposing (..)

import Game.Meta.Types.Network exposing (NIP)


{-| Id de um servidor, só está disponível para gateways.
-}
type alias Id =
    String


{-| Endereço de um endpoint.
-}
type alias EndpointAddress =
    NIP


{-| Id conhecido de um servidor, pode ser um Id para gateways ou um NIP para
endpoints.
-}
type CId
    = GatewayCId Id
    | EndpointCId EndpointAddress


{-| Id das storages de um servidor.
-}
type alias StorageId =
    String


{-| CId do servidor convertido em string, para ser usada como identificador de
uma sessão no sistema operacional.
-}
type alias SessionId =
    String
