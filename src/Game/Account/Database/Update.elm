module Game.Account.Database.Update exposing (update)

import Dict as Dict
import Utils.React as React exposing (React)
import Events.Account.Handlers.ServerPasswordAcquired as ServerPasswordAcquired
import Events.Account.Handlers.VirusCollected as VirusCollected
import Game.Account.Database.Config exposing (..)
import Game.Account.Database.Models exposing (..)
import Game.Account.Database.Messages exposing (..)
import Game.Meta.Types.Network exposing (NIP)
import Game.Shared exposing (ID)


type alias UpdateResponse msg =
    ( Model, React msg )


update : Config msg -> Msg -> Model -> UpdateResponse msg
update config msg model =
    case msg of
        HandlePasswordAcquired data ->
            handlePasswordAcquired data model

        HandleDatabaseAccountRemoved id ->
            onHandleDatabaseAccountRemoved id model

        HandleDatabaseAccountUpdated id account ->
            onHandleDatabaseAccountUpdated id account model

        HandleCollectedVirus data ->
            onHandleCollectedVirus config data model


{-| Saves password for that server, inserts a new server entry
if none is found.
-}
handlePasswordAcquired :
    ServerPasswordAcquired.Data
    -> Model
    -> UpdateResponse msg
handlePasswordAcquired data model =
    let
        servers =
            getHackedServers model

        model_ =
            servers
                |> getHackedServer data.nip
                |> Maybe.withDefault emptyServer
                |> setPassword data.password
                |> flip (insertServer data.nip) servers
                |> flip setHackedServers model
    in
        ( model_, React.none )


onHandleDatabaseAccountRemoved :
    HackedBankAccountID
    -> Model
    -> UpdateResponse msg
onHandleDatabaseAccountRemoved id model =
    let
        model_ =
            { model | bankAccounts = removeBankAccount id model.bankAccounts }
    in
        ( model_, React.none )


onHandleDatabaseAccountUpdated :
    HackedBankAccountID
    -> HackedBankAccount
    -> Model
    -> UpdateResponse msg
onHandleDatabaseAccountUpdated id account model =
    let
        model_ =
            { model
                | bankAccounts = insertBankAccount id account model.bankAccounts
            }
    in
        ( model_, React.none )


onHandleCollectedVirus :
    Config msg
    -> VirusCollected.Data
    -> Model
    -> UpdateResponse msg
onHandleCollectedVirus config data model =
    let
        ( atmId, accNumber, money, virusId, serverNIP ) =
            data

        accountId =
            ( atmId, accNumber )

        hackedServers =
            (getHackedServers model)

        servers =
            resetRunningVirusTime config serverNIP virusId hackedServers

        --TODO: Dispatch a Notification to Player showing earning money
    in
        React.update { model | servers = servers }


resetRunningVirusTime :
    Config msg
    -> NIP
    -> ID
    -> HackedServers
    -> HackedServers
resetRunningVirusTime config nip fileId hackedServers =
    case Dict.get nip hackedServers of
        Just server ->
            let
                viruses =
                    server
                        |> getVirusInstalled
            in
                if Dict.member fileId viruses then
                    viruses
                        |> Dict.get fileId
                        |> Maybe.map (resetVirusTime config)
                        |> Maybe.map (flip (Dict.insert fileId) viruses)
                        |> Maybe.map (\iv -> { server | virusInstalled = iv })
                        |> Maybe.map (flip (Dict.insert nip) hackedServers)
                        |> Maybe.withDefault hackedServers
                else
                    hackedServers

        Nothing ->
            hackedServers



-- Helpers


resetVirusTime : Config msg -> Virus -> Virus
resetVirusTime config virus =
    { virus | runningTime = Just config.lastTick }
