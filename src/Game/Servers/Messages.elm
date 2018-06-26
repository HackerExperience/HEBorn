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

  - ServerMsg

Mensagem para um server em específico.

  - Synced

Recebido como resposta de um request de sincronização.

  - HandleResync

Recebida por dispatch, efetua um request de resync. Requer o CId do servidor.

  - HandleJoinedServer

Recebida por evento quando conectar com o canal de um servidor.

  - HandleDisconnect

Recebido como resposta do request de logout.

-}
type Msg
    = ServerMsg CId ServerMsg
    | Synced CId Server
    | HandleResync CId
    | HandleJoinedServer CId Value
    | HandleDisconnect CId


{-| Mensagens direcionadas a um servidor:

  - HandleLogout

Recebida por dispatch, efetua request de logout do servidor.

  - HandleSetBounce

Recebida por dispatch, muda bounce do servidor.

  - HandleSetEndpoint

Recebida por dispatch, muda endpoint do servidor, só funciona co
servidores gateway.

  - HandleSetActiveNIP

Recebida por dispatch, muda nip do servidor.

  - HandleSetName

Recebida por dispatch, muda nome do servidor, só funciona.

com servidores do jogador

  - FilesystemMsg

Mensagens direcionadas ao domínio de Filesystem do servidor.

  - LogsMsg

Mensagens direcionadas ao domínio de Logs do servidor.

  - ProcessesMsg

Mensagens direcionadas ao domínio de Processes do servidor.

  - HardwareMsg

Mensagens direcionadas ao domínio de Hardware do servidor.

  - TunnelsMsg

Mensagens direcionadas ao domínio de Tunnels do servidor.

  - NotificationsMsg

Mensagens direcionadas ao domínio de Notifications do servidor

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
