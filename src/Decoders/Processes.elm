module Decoders.Processes exposing (..)

import Time exposing (Time)
import Dict exposing (Dict)
import Game.Servers.Processes.Models exposing (..)
import Json.Decode as Decode exposing (..)
import Json.Decode.Pipeline exposing (decode, required, optional, custom)
import Utils.Json.Decode exposing (optionalMaybe)


model : Time -> Maybe Model -> Decoder Model
model now maybeModel =
    let
        model =
            case maybeModel of
                Just model ->
                    model

                Nothing ->
                    initialModel

        apply dict =
            { model
                | processes = dict
                , lastModified = now
            }
    in
        map apply processDict


processDict : Decoder (Dict ID Process)
processDict =
    map Dict.fromList processWithId


processWithId : Decoder (List ( ID, Process ))
processWithId =
    list process


process : Decoder ( ID, Process )
process =
    decode Process
        |> custom type_
        |> required "access" access
        |> required "state" state
        |> optionalMaybe "target_file" file
        |> optionalMaybe "progress" progress
        |> required "network_id" string
        |> required "target_ip" string
        |> andThen insertId


insertId : Process -> Decoder ( ID, Process )
insertId process =
    decode (flip (,) process)
        |> required "process_id" string


type_ : Decoder Type
type_ =
    let
        decodeEncryptor =
            decode EncryptorContent
                |> required "target_log_id" string

        decodeType value =
            case value of
                "cracker" ->
                    succeed Cracker

                "file_download" ->
                    field "data" download

                "file_upload" ->
                    field "data" upload

                "virus_collect" ->
                    succeed VirusCollect

                value ->
                    fail ("Unknown process type `" ++ value ++ "'")
    in
        field "type" string
            |> andThen decodeType


access : Decoder Access
access =
    let
        full =
            decode FullAccess
                |> required "origin_ip" string
                |> required "priority" priority
                |> required "usage" resourcesUsage
                |> optional "source_connection_id" (maybe string) Nothing
                |> optional "target_connection_id" (maybe string) Nothing
                |> optional "source_file" (maybe file) Nothing
                |> map Full

        partial =
            decode PartialAccess
                |> optional "source_connection_id" (maybe string) Nothing
                |> optional "target_connection_id" (maybe string) Nothing
                |> map Partial
    in
        oneOf [ full, partial ]


state : Decoder State
state =
    let
        decode value =
            case value of
                "running" ->
                    succeed Running

                "paused" ->
                    succeed Paused

                "succeeded" ->
                    succeed Succeeded

                "failed" ->
                    succeed <| Failed Unknown

                value ->
                    fail ("Invalid process state `" ++ value ++ "'")
    in
        andThen decode string


priority : Decoder Priority
priority =
    let
        decode num =
            case num of
                1 ->
                    succeed Lowest

                2 ->
                    succeed Low

                3 ->
                    succeed Normal

                4 ->
                    succeed High

                5 ->
                    succeed Highest

                n ->
                    fail ("Unknown priority `" ++ (toString n) ++ "'")
    in
        andThen decode int


resourcesUsage : Decoder ResourcesUsage
resourcesUsage =
    decode ResourcesUsage
        |> required "cpu" usage
        |> required "mem" usage
        |> required "down" usage
        |> required "up" usage


usage : Decoder Usage
usage =
    decode (,)
        |> required "percentage" float
        |> required "absolute" int


progress : Decoder Progress
progress =
    decode Progress
        |> required "creation_date" float
        |> optionalMaybe "completion_date" float
        |> optionalMaybe "percentage" float


file : Decoder ProcessFile
file =
    decode ProcessFile
        |> optionalMaybe "id" string
        |> optionalMaybe "version" float
        |> required "name" string


download : Decoder Type
download =
    decode DownloadContent
        |> required "connection_type" connType
        |> required "storage_id" string
        |> map Download


upload : Decoder Type
upload =
    decode UploadContent
        |> optionalMaybe "storage_id" string
        |> map Upload


connType : Decoder TransferType
connType =
    let
        match str =
            case str of
                "public_ftp" ->
                    PublicFTP

                _ ->
                    PrivateFTP
    in
        map match string
