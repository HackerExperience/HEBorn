module Gen.Filesystem exposing (..)

import Fuzz exposing (Fuzzer)
import Random.Pcg
    exposing
        ( Generator
        , constant
        , map
        , map2
        , andThen
        , sample
        , choices
        , list
        , int
        , float
        )
import Random.Pcg.Extra exposing (andMap)
import Gen.Utils exposing (fuzzer, unique, stringRange, listRange)
import Game.Servers.Filesystem.Models exposing (..)
import Game.Servers.Filesystem.Shared exposing (..)
import Helper.Filesystem exposing (..)


--------------------------------------------------------------------------------
-- Fuzzers
--------------------------------------------------------------------------------


model : Fuzzer Model
model =
    fuzzer genModel


nonEmptyModel : Fuzzer Model
nonEmptyModel =
    fuzzer genNonEmptyModel


fileEntry : Fuzzer FileEntry
fileEntry =
    fuzzer genFileEntry


file : Fuzzer File
file =
    fuzzer genFile


folder : Fuzzer ( Path, Name )
folder =
    fuzzer genFolder


id : Fuzzer Id
id =
    fuzzer genId


name : Fuzzer Name
name =
    fuzzer genName


path : Fuzzer Path
path =
    fuzzer genPath


extension : Fuzzer Extension
extension =
    fuzzer genExtension


size : Fuzzer Size
size =
    fuzzer genSize


crackerModules : Fuzzer CrackerModules
crackerModules =
    fuzzer genCrackerModules


firewallModules : Fuzzer FirewallModules
firewallModules =
    fuzzer genFirewallModules


exploitModules : Fuzzer ExploitModules
exploitModules =
    fuzzer genExploitModules


hasherModules : Fuzzer HasherModules
hasherModules =
    fuzzer genHasherModules


logForgerModules : Fuzzer LogForgerModules
logForgerModules =
    fuzzer genLogForgerModules


logRecoverModules : Fuzzer LogRecoverModules
logRecoverModules =
    fuzzer genLogRecoverModules


encryptorModules : Fuzzer EncryptorModules
encryptorModules =
    fuzzer genEncryptorModules


decryptorModules : Fuzzer DecryptorModules
decryptorModules =
    fuzzer genDecryptorModules


anyMapModules : Fuzzer AnyMapModules
anyMapModules =
    fuzzer genAnyMapModules


simpleModule : Fuzzer { version : Float }
simpleModule =
    fuzzer genSimpleModule


version : Fuzzer Version
version =
    fuzzer genVersion



--------------------------------------------------------------------------------
-- Generators
--------------------------------------------------------------------------------


genModel : Generator Model
genModel =
    choices
        [ constant initialModel
        , genNonEmptyModel
        ]


genNonEmptyModel : Generator Model
genNonEmptyModel =
    genFileEntry
        |> listRange 1 10
        |> map applyModel


genFileEntry : Generator FileEntry
genFileEntry =
    map2 (,) genId genFile


genFile : Generator File
genFile =
    -- TODO: Update this to generate files and folders outside of Root
    let
        keepMap f e =
            map ((,) e) <| f e
    in
        constant File
            |> andMap genName
            |> map flip
            |> andMap (constant [ "" ])
            |> map flip
            |> andMap genSize
            |> map uncurry
            |> andMap (andThen (keepMap genType) genExtension)


genFolder : Generator ( Path, Name )
genFolder =
    map ((,) [ "" ]) unique


genId : Generator Id
genId =
    unique


genName : Generator Name
genName =
    unique


genPath : Generator Path
genPath =
    stringRange 3 16
        |> listRange 1 10


genExtension : Generator Extension
genExtension =
    choices <|
        List.map constant
            [ "exe"
            , "txt"
            , "key"
            ]


genSize : Generator Size
genSize =
    int 0 1000


genType : Extension -> Generator Type
genType ext =
    case ext of
        "exe" ->
            choices
                [ map Cracker genCrackerModules
                , map Firewall genFirewallModules
                , map Exploit genExploitModules
                , map Hasher genHasherModules
                , map LogForger genLogForgerModules
                , map LogRecover genLogRecoverModules
                , map Encryptor genEncryptorModules
                , map Decryptor genDecryptorModules
                , map AnyMap genAnyMapModules
                ]

        "txt" ->
            constant Text

        "key" ->
            constant CryptoKey

        _ ->
            Debug.crash
                ("Can't generate a Filesystem.Type for \""
                    ++ ext
                    ++ "\" extension."
                )


genCrackerModules : Generator CrackerModules
genCrackerModules =
    constant CrackerModules
        |> andMap genSimpleModule
        |> andMap genSimpleModule


genFirewallModules : Generator FirewallModules
genFirewallModules =
    constant FirewallModules
        |> andMap genSimpleModule
        |> andMap genSimpleModule


genExploitModules : Generator ExploitModules
genExploitModules =
    constant ExploitModules
        |> andMap genSimpleModule
        |> andMap genSimpleModule


genHasherModules : Generator HasherModules
genHasherModules =
    map HasherModules genSimpleModule


genLogForgerModules : Generator LogForgerModules
genLogForgerModules =
    constant LogForgerModules
        |> andMap genSimpleModule
        |> andMap genSimpleModule


genLogRecoverModules : Generator LogRecoverModules
genLogRecoverModules =
    map LogRecoverModules genSimpleModule


genEncryptorModules : Generator EncryptorModules
genEncryptorModules =
    constant EncryptorModules
        |> andMap genSimpleModule
        |> andMap genSimpleModule
        |> andMap genSimpleModule
        |> andMap genSimpleModule


genDecryptorModules : Generator DecryptorModules
genDecryptorModules =
    constant DecryptorModules
        |> andMap genSimpleModule
        |> andMap genSimpleModule
        |> andMap genSimpleModule
        |> andMap genSimpleModule


genAnyMapModules : Generator AnyMapModules
genAnyMapModules =
    constant AnyMapModules
        |> andMap genSimpleModule
        |> andMap genSimpleModule


genSimpleModule : Generator { version : Float }
genSimpleModule =
    map (\version -> { version = version }) genVersion


genVersion : Generator Version
genVersion =
    float 0 999



-- Helpers


applyModel : List ( Id, File ) -> Model
applyModel =
    List.foldl (uncurry insertFile) initialModel
