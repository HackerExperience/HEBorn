module Game.Servers.Processes.Models exposing (..)

import Dict exposing (Dict)
import Time exposing (Time)
import Game.Shared
import Game.Network.Types as Network
import Game.Servers.Tunnels.Models exposing (ConnectionID)
import Game.Servers.Logs.Models as Logs
import Utils.Dict as Dict
import Utils.Model.RandomUuid as RandomUuid
import Random.Pcg as Random


type alias Model =
    RandomUuid.Model { processes : Processes }


type alias Processes =
    Dict ID Process


type alias ID =
    Game.Shared.ID


type alias Process =
    { type_ : Type
    , access : Access
    , state : State
    , file : Maybe ProcessFile
    , progress : Maybe Progress
    , network : Network.ID
    , target : Network.IP
    }


type
    Type
    -- TODO: add more data describing each process
    = Cracker
    | Decryptor
    | Encryptor EncryptorContent
    | FileTransference
    | PassiveFirewall
    | Download DownloadContent


type alias EncryptorContent =
    { targetLogId : Logs.ID
    }


type TransferType
    = PublicFTP
    | PrivateFTP


type alias DownloadContent =
    { transferType : TransferType
    , storageId : String
    }



-- owner dependant data


type Access
    = Full FullAccess
    | Partial PartialAccess


type alias FullAccess =
    -- version may be added to the main body
    { origin : Network.IP
    , priority : Priority
    , usage : ResourcesUsage
    , connection : Maybe ConnectionID
    }


type alias PartialAccess =
    { connection_id : Maybe ConnectionID
    }


{-| Starting processes are used for optimistic UI.
-}
type State
    = Starting
    | Running
    | Paused
    | Concluded
    | Succeeded
    | Failed Reason


type Reason
    = Unknown


type alias ProcessFile =
    { id : Maybe FileID
    , version : Maybe Version
    , name : String
    }


type alias FileID =
    Game.Shared.ID


type alias Version =
    Float


type alias FileName =
    String


type Priority
    = Lowest
    | Low
    | Normal
    | High
    | Highest


type alias ResourcesUsage =
    { cpu : Usage
    , mem : Usage
    , down : Usage
    , up : Usage
    }


{-| completionDate and percentage are maybes to keep a progress bar for
paused processes
-}
type alias Progress =
    { creationDate : Time
    , completionDate : Maybe Time
    , percentage : Maybe Percentage
    }


type alias Usage =
    ( Percentage, Unit )


type alias Unit =
    Int


type alias Percentage =
    Float


type alias CompletionDate =
    -- literally the completion date, using that instead of
    -- remaining time to avoid useless model updates
    Time


whenStarted : (Process -> Process) -> Process -> Process
whenStarted func process =
    if isStarting process then
        process
    else
        func process


whenIncomplete : (Process -> Process) -> Process -> Process
whenIncomplete func process =
    if isConcluded process then
        process
    else
        func process


whenFullAccess : (Process -> Process) -> Process -> Process
whenFullAccess func process =
    case getAccess process of
        Full _ ->
            func process

        _ ->
            process


initialModel : Model
initialModel =
    { randomUuidSeed = Random.initialSeed 42
    , processes = Dict.empty
    }


{-| Inserts a Process, can't replace existing ones.
-}
insert : ID -> Process -> Model -> Model
insert id process model =
    Dict.insert id process model.processes
        |> flip setProcesses model


{-| Inserts a Process optimistically, generating a temporary id for it.
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


get : ID -> Model -> Maybe Process
get id model =
    Dict.get id model.processes


{-| Removes a process, can't remove partial access processes.
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


values : Model -> List Process
values =
    .processes >> Dict.values


toList : Model -> List ( ID, Process )
toList =
    .processes >> Dict.toList


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
            , connection = Nothing
            }
    , state = Starting
    , progress = Nothing
    , file = Just file
    , network = Network.getId nip
    , target = target
    }


replace : ID -> ID -> Process -> Model -> Model
replace previousId id process model =
    model.processes
        |> Dict.remove previousId
        |> Dict.insert id process
        |> flip setProcesses model


pause : Process -> Process
pause ({ access } as process) =
    { process | state = Paused }


resume : Process -> Process
resume ({ access } as process) =
    { process | state = Running }


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


failWithReason : Reason -> Process -> Process
failWithReason reason process =
    { process | state = Failed reason }


getState : Process -> State
getState =
    .state


getType : Process -> Type
getType =
    .type_


getAccess : Process -> Access
getAccess =
    .access


getTarget : Process -> Network.NIP
getTarget process =
    Network.toNip process.network process.target


getOrigin : Process -> Maybe Network.NIP
getOrigin process =
    case process.access of
        Full data ->
            Just <| Network.toNip process.network data.origin

        Partial _ ->
            Nothing


getVersion : Process -> Maybe Version
getVersion { file } =
    Maybe.andThen .version file


getFileID : Process -> Maybe FileID
getFileID { file } =
    Maybe.andThen .id file


getFileName : Process -> Maybe FileName
getFileName { file } =
    Maybe.map .name file


getPriority : Process -> Maybe Priority
getPriority { access } =
    case access of
        Full data ->
            Just data.priority

        Partial _ ->
            Nothing


getUsage : Process -> Maybe ResourcesUsage
getUsage { access } =
    case access of
        Full data ->
            Just data.usage

        Partial _ ->
            Nothing


getProgress : Process -> Maybe Progress
getProgress =
    .progress


getProgressPercentage : Process -> Maybe Percentage
getProgressPercentage =
    getProgress >> Maybe.andThen .percentage


getCompletionDate : Process -> Maybe CompletionDate
getCompletionDate =
    getProgress >> Maybe.andThen .completionDate


getConnectionId : Process -> Maybe ConnectionID
getConnectionId { access } =
    case access of
        Full data ->
            data.connection

        Partial { connection_id } ->
            connection_id


getName : Process -> String
getName { type_ } =
    case type_ of
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


getPercentUsage : Usage -> Float
getPercentUsage =
    Tuple.first


getUnitUsage : Usage -> Int
getUnitUsage =
    Tuple.second


setProcesses : Processes -> Model -> Model
setProcesses processes model =
    { model | processes = processes }


isRecurive : Process -> Bool
isRecurive process =
    process
        |> getProgress
        |> Maybe.map (always False)
        |> Maybe.withDefault True


{-| This function will return True for processes in any conclusion state
(Concluded, Succeeded and Failed).
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


isStarting : Process -> Bool
isStarting process =
    case getState process of
        Starting ->
            True

        _ ->
            False


newProcessFile : ( Maybe FileID, Maybe Version, FileName ) -> ProcessFile
newProcessFile ( id, version, name ) =
    { id = id
    , version = version
    , name = name
    }


unknownProcessFile : ProcessFile
unknownProcessFile =
    { id = Nothing
    , version = Nothing
    , name = "..."
    }
