module Game.Servers.Processes.Models exposing (..)

{-| Processos são tarefas realizadas por servidores, eles causam efeitos quando
concluídos e consomem recursos enquanto isso.
-}

import Dict exposing (Dict)
import Time exposing (Time)
import Random.Pcg as Random
import Utils.Model.RandomUuid as RandomUuid
import Game.Meta.Types.Network as Network
import Game.Servers.Tunnels.Models exposing (ConnectionID)
import Game.Servers.Logs.Models as Logs
import Game.Servers.Processes.Shared exposing (..)


{-| Model, contém os processos, a última vez que a model foi atualizada e uma
seed que é utilizada para os processos otimistas.
-}
type alias Model =
    { processes : Processes
    , lastModified : Time
    , randomUuidSeed : Random.Seed
    }


{-| Estrutura de dados que armazena os processos.
-}
type alias Processes =
    Dict ID Process


{-| Estrutura de dados que armazena um processo, processos possuem os
seguintes dados:

  - type_: Tipo de processo.
  - access: Nível de acesso do jogador.
  - state: Estado do processo.
  - file: Arquivo do processo (caso ele seja um software).
  - progress: Network que o processo está utilizando.
  - network: IP que o processo está utilizando.

-}
type alias Process =
    { type_ : Type
    , access : Access
    , state : State
    , file : Maybe ProcessFile
    , progress : Maybe Progress
    , network : Network.ID
    , target : Network.IP
    }


{-| Tipo do processo, a maioria dos tipos são tipos de software:

  - Cracker

Rouba senha de um servidor.

  - Decryptor

Descriptografa arquivos.

  - Encryptor

Criptografa arquivos.

  - FileTransference

Transfere arquivo de um servidor para outro.

  - PassiveFirewall

Firewall que executa passivamente.

  - Download

Download de arquivo.

  - Upload

Upload de arquivo.

  - VirusCollect

Coleta dinheiro gerado por virus.

-}
type
    Type
    -- TODO: adicionar mais dados descrevendo peculiaridades de cada tipo de
    -- processo
    = Cracker
    | Decryptor
    | Encryptor EncryptorContent
    | FileTransference
    | PassiveFirewall
    | Download DownloadContent
    | Upload UploadContent
    | VirusCollect


{-| Dados específicos de processos de Encryptor.
-}
type alias EncryptorContent =
    { targetLogId : Logs.ID
    }


{-| Dados específicos de processos de Transfer.
-}
type TransferType
    = PublicFTP
    | PrivateFTP


{-| Dados específicos de processos de Download.
-}
type alias DownloadContent =
    { transferType : TransferType
    , storageId : String
    }


{-| Dados específicos de processos de Updload.
-}
type alias UploadContent =
    { storageId : Maybe String
    }


{-| Nível de acesso que o jogador tem ao processo.
-}
type Access
    = Full FullAccess
    | Partial PartialAccess


{-| Dados que o jogador tem acessso quando tiver acesso total ao processo.
A versão do software pode ser adicionada aqui.
-}
type alias FullAccess =
    { origin : Network.IP
    , priority : Priority
    , usage : ResourcesUsage
    , source_connection : Maybe ConnectionID
    , target_connection : Maybe ConnectionID
    , source_file : Maybe ProcessFile
    }


{-| Dados que o jogador tem acesso quando tiver acesso parcial ao processo.
-}
type alias PartialAccess =
    { source_connection_id : Maybe ConnectionID
    , target_connection_id : Maybe ConnectionID
    }


{-| Estado do processo:

  - Starting

Processo otimista, ainda não foi criado no server side.

  - Running

Processo em execução.

  - Paused

Processo pausado.

  - Concluded

Concluído de forma otimista, não se sabe se foi com sucesso ou não.

  - Succeeded

Processo concluído com sucesso.

  - Failed

Processo concluído ou terminado com falha.

-}
type State
    = Starting
    | Running
    | Paused
    | Concluded
    | Succeeded
    | Failed Reason


{-| Causa da falha do processo, por enquanto as causas são desconhecidos.
-}
type Reason
    = Unknown


{-| Arquivo do processo, acesso ao id do arquivo e versão são opcionais.
Processos que não usam softwares não possuem versão.
-}
type alias ProcessFile =
    { id : Maybe FileID
    , version : Maybe Version
    , name : String
    }


{-| Versão do software do processo.
-}
type alias Version =
    Float


{-| Nome do arquivo do processo.
-}
type alias FileName =
    String


{-| Prioridade do Processo.
-}
type Priority
    = Lowest
    | Low
    | Normal
    | High
    | Highest


{-| Recursos sendo usados pelo Processo.
-}
type alias ResourcesUsage =
    { cpu : Usage
    , mem : Usage
    , down : Usage
    , up : Usage
    }


{-| Progresso do processo, inclui data de criação, data de término (opcional),
e porcentagem de conclusão (também opcional pois existem processos que não
terminam).
-}
type alias Progress =
    { creationDate : Time
    , completionDate : Maybe Time
    , percentage : Maybe Percentage
    }


{-| Uso de recurso, em porcentagem e unidade de nedida,
-}
type alias Usage =
    ( Percentage, Unit )


{-| Unidade de medida para recursos, pode representar qualquer unidade, como
megabytes, gigabytes, cpu time. Dependendo do
-}
type alias Unit =
    Int


{-| Unidade em porcentagem, serve para consumo de recursos e taxa de compleção
do
-}
type alias Percentage =
    Float


{-| Data em que o processo será concluído.

Não tente mudar isso para "tempo faltando para concluir o processo", isso
causaria updates de model desnecessários.

-}
type alias CompletionDate =
    Time


{-| Aplica função caso o processo esteja sendo inicializado.
-}
whenStarted : (Process -> Process) -> Process -> Process
whenStarted func process =
    if isStarting process then
        process
    else
        func process


{-| Aplica função caso o processo esteja em execução.
-}
whenIncomplete : (Process -> Process) -> Process -> Process
whenIncomplete func process =
    if isConcluded process then
        process
    else
        func process


{-| Aplica função caso o jogador tenha acesso total ao processo.
-}
whenFullAccess : (Process -> Process) -> Process -> Process
whenFullAccess func process =
    case getAccess process of
        Full _ ->
            func process

        _ ->
            process


{-| Model inicial, a seed inicial é a resposta de tudo.
-}
initialModel : Model
initialModel =
    { randomUuidSeed = Random.initialSeed 42
    , processes = Dict.empty
    , lastModified = 0
    }


{-| Pega data da ultima vez que o servidor pediu para atualizar a model.
-}
getLastModified : Model -> Time
getLastModified =
    .lastModified


{-| Insere um processo, não substitui processo existente.
-}
insert : ID -> Process -> Model -> Model
insert id process model =
    Dict.insert id process model.processes
        |> flip setProcesses model


{-| Insere um processo otimisticamente, gerando um Id temporário para ele.
-}
insertOptimistic : Process -> Model -> ( ID, Model )
insertOptimistic process model0 =
    let
        ( model1, id ) =
            RandomUuid.newUuid model0

        model2 =
            Dict.insert id process model1.processes
                |> flip setProcesses model1
    in
        ( id, model2 )


{-| Tenta pegar o Processo.
-}
get : ID -> Model -> Maybe Process
get id model =
    Dict.get id model.processes


{-| Remove um processo, não consegue remover processos que o jogador não tiver
acesso total.
-}
remove : ID -> Model -> Model
remove id model =
    case get id model of
        Just process ->
            case process.state of
                Starting ->
                    model

                _ ->
                    Dict.remove id model.processes
                        |> flip setProcesses model

        Nothing ->
            model


{-| Retorna lista de processos.
-}
values : Model -> List Process
values =
    .processes >> Dict.values


{-| Retorna lista de processos com seus ids.
-}
toList : Model -> List ( ID, Process )
toList =
    .processes >> Dict.toList


{-| Cria um novo processo otimisticamente.
-}
newOptimistic :
    Type
    -> Network.NIP
    -> Network.IP
    -> ProcessFile
    -> Process
newOptimistic type_ nip target file =
    { type_ = type_
    , access =
        Full
            { origin = Network.getIp nip
            , priority = Normal
            , usage =
                { cpu = ( 0.0, 0 )
                , mem = ( 0.0, 0 )
                , down = ( 0.0, 0 )
                , up = ( 0.0, 0 )
                }
            , source_connection = Nothing
            , target_connection = Nothing
            , source_file = Nothing
            }
    , state = Starting
    , progress = Nothing
    , file = Just file
    , network = Network.getId nip
    , target = target
    }


{-| Substitui um processo.
-}
replace : ID -> ID -> Process -> Model -> Model
replace previousId id process model =
    model.processes
        |> Dict.remove previousId
        |> Dict.insert id process
        |> flip setProcesses model


{-| Pausa um processo.
-}
pause : Process -> Process
pause process =
    { process | state = Paused }


{-| Despausa um processo.
-}
resume : Process -> Process
resume process =
    { process | state = Running }


{-| Conclui um processo, aceita um Maybe Bool para definir um estado de
conclusão mais preciso.
-}
conclude : Maybe Bool -> Process -> Process
conclude succeeded process =
    let
        state =
            case succeeded of
                Just True ->
                    Succeeded

                Just False ->
                    Failed Unknown

                Nothing ->
                    Concluded
    in
        { process | state = state }


{-| Conclui processo com status de falha e razão para falha.
-}
failWithReason : Reason -> Process -> Process
failWithReason reason process =
    { process | state = Failed reason }


{-| Retorna estado do processo.
-}
getState : Process -> State
getState =
    .state


{-| Retorna tipo do processo.
-}
getType : Process -> Type
getType =
    .type_


{-| Retorna dados condicionalmente acessíveis do processo.
-}
getAccess : Process -> Access
getAccess =
    .access


{-| Retorna o NIP que o processo afeta.
-}
getTarget : Process -> Network.NIP
getTarget process =
    Network.toNip process.network process.target


{-| Retorna o NIP de origem do processo.
-}
getOrigin : Process -> Maybe Network.NIP
getOrigin process =
    case getAccess process of
        Full data ->
            Just <| Network.toNip process.network data.origin

        Partial _ ->
            Nothing


{-| Retorna a versão do processo.
-}
getVersion : Process -> Maybe Version
getVersion =
    getFile >> Maybe.andThen .version


{-| Retorna o arquivo do processo.
-}
getFile : Process -> Maybe ProcessFile
getFile =
    .file


{-| Retorna o id do arquivo do processo.
-}
getFileID : Process -> Maybe FileID
getFileID =
    getFile >> Maybe.andThen .id


{-| Retorna o nome do arquivo do processo.
-}
getFileName : Process -> Maybe FileName
getFileName =
    getFile >> Maybe.map .name


{-| Retorna a prioridade do processo.
-}
getPriority : Process -> Maybe Priority
getPriority process =
    case getAccess process of
        Full data ->
            Just data.priority

        Partial _ ->
            Nothing


{-| Retorna os recursos que estão sendo usados pelo processo.
-}
getUsage : Process -> Maybe ResourcesUsage
getUsage process =
    case getAccess process of
        Full data ->
            Just data.usage

        Partial _ ->
            Nothing


{-| Retorna progresso do processo.
-}
getProgress : Process -> Maybe Progress
getProgress =
    .progress


{-| Retorna progresso do processo em forma de porcentagem.
-}
getProgressPercentage : Process -> Maybe Percentage
getProgressPercentage =
    getProgress >> Maybe.andThen .percentage


{-| Retorna a data de conclusão prevista para o processo.
-}
getCompletionDate : Process -> Maybe CompletionDate
getCompletionDate =
    getProgress >> Maybe.andThen .completionDate


{-| Retorna a ConnectionId do processo.
-}
getConnectionId : Process -> Maybe ConnectionID
getConnectionId process =
    case getAccess process of
        Full data ->
            data.source_connection

        Partial { source_connection_id } ->
            source_connection_id


{-| Retorna o nome do processo, depende do tipo do mesmo.
-}
getName : Process -> String
getName process =
    case getType process of
        Cracker ->
            "Cracker"

        Decryptor ->
            "Decryptor"

        Encryptor _ ->
            "Encryptor"

        FileTransference ->
            "File Transference"

        PassiveFirewall ->
            "Passive Firewall"

        Download _ ->
            "Download"

        Upload _ ->
            "Upload"

        VirusCollect ->
            "Virus Collect"


{-| Pega a parte percentual da Usage.
-}
getPercentUsage : Usage -> Percentage
getPercentUsage =
    Tuple.first


{-| Pega a parte unitária da Usage.
-}
getUnitUsage : Usage -> Int
getUnitUsage =
    Tuple.second


{-| Atualiza processos da model.
-}
setProcesses : Processes -> Model -> Model
setProcesses processes model =
    { model | processes = processes }


{-| Retorna se um processo é recursivo.
-}
isRecurive : Process -> Bool
isRecurive process =
    process
        |> getProgress
        |> Maybe.map (always False)
        |> Maybe.withDefault True


{-| Retorna True se o status do processo for Concluded, Succeeded or Failed.
-}
isConcluded : Process -> Bool
isConcluded process =
    case getState process of
        Concluded ->
            True

        Succeeded ->
            True

        Failed _ ->
            True

        _ ->
            False


{-| Retorna true se o status do processo for Starting.
-}
isStarting : Process -> Bool
isStarting process =
    case getState process of
        Starting ->
            True

        _ ->
            False


{-| Cria um ProcessFile de arquivo conhecido.
-}
newProcessFile : ( Maybe FileID, Maybe Version, FileName ) -> ProcessFile
newProcessFile ( id, version, name ) =
    { id = id
    , version = version
    , name = name
    }


{-| ProcessFile de arquivo desconhecido.
-}
unknownProcessFile : ProcessFile
unknownProcessFile =
    { id = Nothing
    , version = Nothing
    , name = "..."
    }
