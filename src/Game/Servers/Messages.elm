module Game.Servers.Messages exposing (Msg(..), ServerMsg(..))

import Json.Decode exposing (Value)
import Game.Account.Bounces.Shared as Bounces
import Game.Meta.Types.Network as Network
import Game.Servers.Filesystem.Messages as Filesystem
import Game.Servers.Logs.Messages as Logs
import Game.Servers.Processes.Messages as Processes
import Game.Servers.Hardware.Messages as Hardware
import Game.Servers.Tunnels.Messages as Tunnels
import Game.Servers.Notifications.Messages as Notifications
import Game.Servers.Shared exposing (..)
import Game.Servers.Models exposing (..)


{-| Mensagens:

    - ServerMsg: mensagem para um server em específico
    - Synced: recebido como resposta de um request de sincronização
    - HandleResync: recebida por dispatch, efetua um request de resync
    - HandleJoinedServer: recebida por evento quando conectar com o canal de
        um servidor
    - HandleDisconnect: recebido como resposta do request de logout

-}
type Msg
    = ServerMsg CId ServerMsg
    | Synced CId Server
    | HandleResync CId
    | HandleJoinedServer CId Value
    | HandleDisconnect CId


{-| Mensagens direcionadas a um servidor:

    - HandleLogout: recebida por dispatch, efetua request de logout do servidor
    - HandleSetBounce: recebida por dispatch, muda bounce do servidor
    - HandleSetEndpoint: recebida por dispatch, muda endpoint do servidor, só
        funciona com servidores gateway
    - HandleSetActiveNIP: recebida por dispatch, muda nip do servidor
    - HandleSetName: recebida por dispatch, muda nome do servidor, só funciona
    com servidores do jogador
    - FilesystemMsg: mensagens direcionadas ao domínio de Filesystem do servidor
    - LogsMsg: mensagens direcionadas ao domínio de Logs do servidor
    - ProcessesMsg: mensagens direcionadas ao domínio de Processes do servidor
    - HardwareMsg: mensagens direcionadas ao domínio de Hardware do servidor
    - TunnelsMsg: mensagens direcionadas ao domínio de Tunnels do servidor
    - NotificationsMsg: mensagens direcionadas ao domínio de Notifications do
    servidor

-}
type ServerMsg
    = HandleLogout
    | HandleSetBounce (Maybe Bounces.ID)
    | HandleSetEndpoint (Maybe CId)
    | HandleSetActiveNIP Network.NIP
    | HandleSetName String
    | FilesystemMsg StorageId Filesystem.Msg
    | LogsMsg Logs.Msg
    | ProcessesMsg Processes.Msg
    | HardwareMsg Hardware.Msg
    | TunnelsMsg Tunnels.Msg
    | NotificationsMsg Notifications.Msg
