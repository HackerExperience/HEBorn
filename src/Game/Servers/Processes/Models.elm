module Game.Servers.Processes.Models exposing (..)

import Dict exposing (Dict)
import Time exposing (Time)
import Game.Shared
import Game.Network.Types exposing (NIP)
import Game.Servers.Tunnels.Models exposing (ConnectionID)
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
    , target : ServerID
    }


type
    Type
    -- TODO: add more data describing each process
    = Cracker
    | Decryptor
    | Encryptor
    | FileTransference
    | PassiveFirewall


type alias ServerID =
    Game.Shared.ID



-- owner dependant data


type Access
    = Full FullAccess
    | Partial PartialAccess


type alias FullAccess =
    -- version may be added to the main body
    { origin : ServerID
    , priority : Priority
    , usage : ResourcesUsage
    , connection : Maybe ConnectionID
    }


type alias PartialAccess =
    { originConnection : Maybe ( ServerID, ConnectionID )
    }


{-| Starting processes are used for optimistic UI.
-}
type State
    = Starting
    | Running
    | Paused
    | Completed (Maybe Status)


type Status
    = Success
    | Failure Reason


type Reason
    = Misc String


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
    , ram : Usage
    , downlink : Usage
    , uplink : Usage
    }


type alias Progress =
    ( Percentage, Maybe CompletionDate )


type alias Usage =
    ( Percentage, Unit )


type alias Unit =
    String


type alias Percentage =
    Float


type alias CompletionDate =
    -- literally the completion date, using that instead of
    -- remaining time to avoid useless model updates
    Time


initialModel : Model
initialModel =
    { randomUuidSeed = Random.initialSeed 42
    , processes = Dict.empty
    }


{-| Inserts a Process, can't replace existing ones.
-}
insert : ID -> Process -> Model -> Model
insert id process model =
    case Dict.get id model.processes of
        Nothing ->
            Dict.insert id process model.processes
                |> flip setProcesses model

        Just _ ->
            model


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


{-| Replace a process, can't replace optimistic ones as they shouldn't be
changed until replaced with real ones.
-}
upsert : ID -> Process -> Model -> Model
upsert id process model =
    case process.state of
        Starting ->
            model

        _ ->
            Dict.insert id process model.processes
                |> flip setProcesses model


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
    -> ServerID
    -> ServerID
    -> ProcessFile
    -> Process
newOptimistic t origin target file =
    { type_ = t
    , access =
        Full
            { origin = origin
            , priority = Normal
            , usage =
                { cpu = ( 0.0, "" )
                , ram = ( 0.0, "" )
                , downlink = ( 0.0, "" )
                , uplink = ( 0.0, "" )
                }
            , connection = Nothing
            }
    , state = Starting
    , progress = Just ( 0.0, Nothing )
    , file = Just file
    , target = target
    }


replace : ID -> ID -> Process -> Model -> Model
replace previousId id process model =
    model.processes
        |> Dict.remove previousId
        |> Dict.insert id process
        |> flip setProcesses model


pause : Process -> Process
pause ({ state, access } as process) =
    case access of
        Full _ ->
            case state of
                Completed _ ->
                    process

                _ ->
                    { process | state = Paused }

        Partial _ ->
            process


resume : Process -> Process
resume ({ state, access } as process) =
    case access of
        Full _ ->
            case state of
                Completed _ ->
                    process

                _ ->
                    { process | state = Running }

        Partial _ ->
            process


complete : Maybe Status -> Process -> Process
complete status ({ state, access } as process) =
    case access of
        Full _ ->
            case state of
                Completed _ ->
                    process

                _ ->
                    { process | state = Completed status }

        Partial _ ->
            process


getState : Process -> State
getState =
    .state


getType : Process -> Type
getType =
    .type_


getAccess : Process -> Access
getAccess =
    .access


getTarget : Process -> ServerID
getTarget =
    .target


getOrigin : Process -> Maybe ServerID
getOrigin { access } =
    case access of
        Full data ->
            Just data.origin

        Partial { originConnection } ->
            originConnection
                |> Maybe.map Tuple.first


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


getProgressPct : Process -> Maybe Percentage
getProgressPct =
    getProgress >> Maybe.map Tuple.first


getCompletionDate : Process -> Maybe CompletionDate
getCompletionDate =
    getProgress >> Maybe.andThen Tuple.second


getConnectionId : Process -> Maybe ConnectionID
getConnectionId { access } =
    case access of
        Full data ->
            data.connection

        Partial { originConnection } ->
            originConnection
                |> Maybe.map Tuple.second


getName : Process -> String
getName { type_ } =
    case type_ of
        Cracker ->
            "Cracker"

        Decryptor ->
            "Decryptor"

        Encryptor ->
            "Encryptor"

        FileTransference ->
            "File Transference"

        PassiveFirewall ->
            "Passive Firewall"


getPercentUsage : Usage -> Float
getPercentUsage =
    Tuple.first


getUnitUsage : Usage -> String
getUnitUsage =
    Tuple.second


setProcesses : Processes -> Model -> Model
setProcesses processes model =
    { model | processes = processes }


typeFromName : String -> Maybe Type
typeFromName t =
    -- this may change a little, to acomodate more data
    case t of
        "Cracker" ->
            Just Cracker

        "Decryptor" ->
            Just Decryptor

        "Encryptor" ->
            Just Encryptor

        "File Transference" ->
            Just FileTransference

        "Passive Firewall" ->
            Just PassiveFirewall

        _ ->
            Nothing


isRecurive : Process -> Bool
isRecurive process =
    process
        |> getProgress
        |> Maybe.map (always False)
        |> Maybe.withDefault True


newProcessFile : ( Maybe FileID, Maybe Version, FileName ) -> ProcessFile
newProcessFile ( id, version, name ) =
    { id = id
    , version = version
    , name = name
    }
