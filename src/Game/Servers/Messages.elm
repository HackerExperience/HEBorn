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

  - `ServerMsg`

Mensagem para um server em específico.

  - `Synced`

Recebido como resposta de um request de sincronização.

  - `HandleResync` (dispatch)

Efetua um request de resync. Requer o `CId` do servidor.
Deve ser recebeida após a model de um servidor tornar-se inconsistente.

  - `HandleJoinedServer` (evento)

Insere dados do bootstrap na model.
Recebida quando se conectar ao canal de um servidor.

  - `HandleDisconnect`

Recebido como resposta do request de logout.

-}
type Msg
    = ServerMsg CId ServerMsg
    | Synced CId Server
    | HandleResync CId
    | HandleJoinedServer CId Value
    | HandleDisconnect CId


{-| Mensagens direcionadas a um servidor:

  - `HandleLogout` (dispatch)

Efetua request de logout do servidor.

  - `HandleSetBounce` (dispatch)

Muda o bounce ativo do servidor, só funciona com endpoints. Requer um
Maybe Bounces.ID que será o novo bounce do servidor.

  - `HandleSetEndpoint` (dispatch)

Muda endpoint ativo do servidor, só funciona com servidores gateway. Requer um
Maybe CId que será o o novo endpoint ativo do servidor.

  - `HandleSetActiveNIP` (dispatch)

Muda o NIP ativo do servidor. Requer um NIP que será o novo NIP ativo.

  - `HandleSetName` (dispatch)

Muda nome do servidor, só funciona com servidores do jogador. Requer uma String
que será o novo nome do servidor.

  - `FilesystemMsg`

Mensagens direcionadas ao domínio de Filesystem do servidor.

  - `LogsMsg`

Mensagens direcionadas ao domínio de Logs do servidor.

  - `ProcessesMsg`

Mensagens direcionadas ao domínio de Processes do servidor.

  - `HardwareMsg`

Mensagens direcionadas ao domínio de Hardware do servidor.

  - `TunnelsMsg`

Mensagens direcionadas ao domínio de Tunnels do servidor.

  - `NotificationsMsg`

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
