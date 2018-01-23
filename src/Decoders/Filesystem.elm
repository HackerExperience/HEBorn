module Decoders.Filesystem exposing (..)

import Dict exposing (Dict)
import Json.Decode
    exposing
        ( Decoder
        , map
        , andThen
        , succeed
        , fail
        , oneOf
        , field
        , list
        , dict
        , int
        , float
        , string
        )
import Json.Decode.Pipeline exposing (decode, required, custom)
import Utils.Json.Decode exposing (commonError)
import Game.Servers.Filesystem.Models as Filesystem
import Game.Servers.Filesystem.Shared as Filesystem


{-| A parser that merges the response with the model, parses:

    ```
    dict string
        (list
            { id :
                string
            , name:
                string
            , extension:
                string
            , path:
                string
            , size:
                int
            , type:
                (string) type
            , modules:
                modules for type
            }
        )
    ```

`type` defines expected modules:

    ```
    enum: "cracker"
        | "firewall"
        | "exploit"
        | "hasher"
        | "log_forger"
        | "log_recover"
        | "encryptor"
        | "decryptor"
        | "anymap"
        | "text"
        | "crypto_key"
    ```

`modules` type varies according to the software type:

    ```
    modules for "cracker":
        bruteforce: simple_module
        overflow: simple_module

    modules for "firewall":
        fwl_active: simple_module
        fwl_passive: simple_module

    modules for "exploit":
        ftp: simple_module
        ssh: simple_module

    modules for "hasher":
        password: simple_module

    modules for "log_forger":
        log_create: simple_module
        log_edit: simple_module

    modules for "log_recover":
        log_recover: simple_module

    modules for "encryptor":
        enc_file: simple_module
        enc_log: simple_module
        enc_connection: simple_module
        enc_process: simple_module

    modules for "decryptor":
        dec_file: simple_module
        dec_log: simple_module
        dec_connection: simple_module
        dec_process: simple_module

    modules for "anymap":
        map_geo: simple_module
        map_net: simple_module

    modules for "text":
        ---

    modules for "crypto_key":
        ---
    ```

`simple_module` is a generic module format for modules without special fields:

    ```
    version: float
    ```

Some types like `text` and `crypto_key` won't required the `modules` field.

-}
model : Maybe Filesystem.Model -> Decoder Filesystem.Model
model =
    let
        -- convert maybe model into model
        withDefault maybeFs =
            case maybeFs of
                Just fs ->
                    fs

                Nothing ->
                    Filesystem.initialModel

        -- a fold to insert files into model
        insertFiles =
            Filesystem.insertFile
                |> uncurry
                |> List.foldl
                |> flip

        -- insert folder and its files
        folderReducer location files =
            let
                path =
                    Filesystem.toPath location

                parent =
                    Filesystem.parentPath path

                name =
                    Filesystem.pathBase path
            in
                Filesystem.insertFolder parent name
                    >> insertFiles files

        -- insert folders and its files
        insertContents =
            Dict.foldl folderReducer

        -- transform server response
        mapEntries =
            flip map <| dict <| list fileEntry
    in
        withDefault >> insertContents >> mapEntries


entry : Decoder Filesystem.Entry
entry =
    oneOf
        [ map (uncurry Filesystem.FileEntry) fileEntry
        , map (uncurry Filesystem.FolderEntry) folder
        ]


folder : Decoder ( Filesystem.Path, Filesystem.Name )
folder =
    decode (,)
        |> required "path" path
        |> required "name" string


fileEntry : Decoder Filesystem.FileEntry
fileEntry =
    decode (,)
        |> required "id" string
        |> custom file


file : Decoder Filesystem.File
file =
    decode Filesystem.File
        |> required "name" string
        |> required "extension" string
        |> required "path" path
        |> required "size" int
        |> custom fileType


fileType : Decoder Filesystem.Type
fileType =
    let
        decodeField =
            field "type" string

        modulesFor =
            field "modules"

        decodeModules type_ =
            case type_ of
                "cracker" ->
                    map Filesystem.Cracker <| modulesFor cracker

                "firewall" ->
                    map Filesystem.Firewall <| modulesFor firewall

                "exploit" ->
                    map Filesystem.Exploit <| modulesFor exploit

                "hasher" ->
                    map Filesystem.Hasher <| modulesFor hasher

                "log_forger" ->
                    map Filesystem.LogForger <| modulesFor logForger

                "log_recover" ->
                    map Filesystem.LogRecover <| modulesFor logRecover

                "encryptor" ->
                    map Filesystem.Encryptor <| modulesFor encryptor

                "decryptor" ->
                    map Filesystem.Decryptor <| modulesFor decryptor

                "anymap" ->
                    map Filesystem.AnyMap <| modulesFor anyMap

                "text" ->
                    succeed Filesystem.Text

                "crypto_key" ->
                    succeed Filesystem.CryptoKey

                error ->
                    fail <| commonError "type" error
    in
        andThen decodeModules decodeField


path : Decoder Filesystem.Path
path =
    map Filesystem.toPath string



-- module decode helpers


simpleModule : Decoder { version : Filesystem.Version }
simpleModule =
    let
        constructor version =
            { version = version }
    in
        decode constructor
            |> version


version : Decoder (Float -> b) -> Decoder b
version =
    required "version" float



-- software types


cracker : Decoder Filesystem.CrackerModules
cracker =
    decode Filesystem.CrackerModules
        |> required "bruteforce" simpleModule
        |> required "overflow" simpleModule


firewall : Decoder Filesystem.FirewallModules
firewall =
    decode Filesystem.FirewallModules
        |> required "fwl_active" simpleModule
        |> required "fwl_passive" simpleModule


exploit : Decoder Filesystem.ExploitModules
exploit =
    decode Filesystem.ExploitModules
        |> required "ftp" simpleModule
        |> required "ssh" simpleModule


hasher : Decoder Filesystem.HasherModules
hasher =
    decode Filesystem.HasherModules
        |> required "password" simpleModule


logForger : Decoder Filesystem.LogForgerModules
logForger =
    decode Filesystem.LogForgerModules
        |> required "log_create" simpleModule
        |> required "log_edit" simpleModule


logRecover : Decoder Filesystem.LogRecoverModules
logRecover =
    decode Filesystem.LogRecoverModules
        |> required "log_recover" simpleModule


encryptor : Decoder Filesystem.EncryptorModules
encryptor =
    decode Filesystem.EncryptorModules
        |> required "enc_file" simpleModule
        |> required "enc_log" simpleModule
        |> required "enc_connection" simpleModule
        |> required "enc_process" simpleModule


decryptor : Decoder Filesystem.DecryptorModules
decryptor =
    decode Filesystem.DecryptorModules
        |> required "dec_file" simpleModule
        |> required "dec_log" simpleModule
        |> required "dec_connection" simpleModule
        |> required "dec_process" simpleModule


anyMap : Decoder Filesystem.AnyMapModules
anyMap =
    decode Filesystem.AnyMapModules
        |> required "map_geo" simpleModule
        |> required "map_net" simpleModule
