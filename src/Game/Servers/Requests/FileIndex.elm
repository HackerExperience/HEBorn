module Game.Servers.Requests.FileIndex
    exposing
        ( Response(..)
        , request
        , receive
        , Index
        , Files
        , File
        , SoftwareType(..)
        , SoftwareModule(..)
        , CrackerModule(..)
        , ExploitModule(..)
        , FirewallModule(..)
        , HasherModule(..)
        , LogForgerModule(..)
        , LogRecoverModule(..)
        , EncryptorModule(..)
        , DecryptorModule(..)
        )

import Date exposing (Date)
import Dict exposing (Dict)
import Json.Decode
    exposing
        -- this request contains no payload, so no problems with importing this
        ( Decoder
        , Value
        , decodeValue
        , succeed
        , fail
        , andThen
        , list
        , dict
        , string
        , int
        )
import Json.Decode.Pipeline exposing (decode, required, hardcoded)
import Utils.Json.Decode exposing (date)
import Requests.Requests as Requests
import Requests.Topics exposing (Topic(..))
import Requests.Types exposing (ConfigSource, Code(..), emptyPayload)
import Game.Servers.Messages exposing (..)


type Response
    = OkResponse Index
    | NoOp


type alias Index =
    Dict String Files


type alias Files =
    List File


type alias File =
    { id : String
    , path : String -- full path
    , type_ : SoftwareType
    , size : Int
    , insertedAt : Date
    , updatedAt : Date

    -- , modules : {}
    -- , meta : {}
    }


type SoftwareType
    = Text
    | Cracker
    | Exploit
    | Firewall
    | Hasher
    | LogForger
    | LogRecover
    | Encryptor
    | Decryptor
    | AnyMap
    | CryptoKey



-- Software Modules draft


type SoftwareModule
    = CrackerModule CrackerModule
    | ExploitModule ExploitModule
    | FirewallModule FirewallModule
    | HasherModule HasherModule
    | LogForgerModule LogForgerModule
    | LogRecoverModule LogRecoverModule
    | EncryptorModule EncryptorModule
    | DecryptorModule DecryptorModule


type CrackerModule
    = PasswordCracker


type ExploitModule
    = FtpExploit
    | SshExploit


type FirewallModule
    = ActiveFirewall
    | PassiveFirewall


type HasherModule
    = PasswordHasher


type LogForgerModule
    = CreateLogForger
    | EditLogForger


type LogRecoverModule
    = RecoverLogRecover


type EncryptorModule
    = FileEncryptor
    | LogEncryptor
    | ConnectionEncryptor
    | ProcessEncryptor


type DecryptorModule
    = FileDecryptor
    | LogDecryptor
    | ConnectionDecryptor
    | ProcessDecryptor


request : ConfigSource a -> Cmd Msg
request =
    Requests.request ServerFileIndexTopic
        (FileIndexRequest >> Request)
        Nothing
        emptyPayload


receive : Code -> Value -> Response
receive code json =
    case code of
        OkCode ->
            json
                |> decoder
                |> Result.map OkResponse
                |> Requests.report

        _ ->
            -- TODO: handle errors
            NoOp



-- internals


decoder : Value -> Result String Index
decoder json =
    decodeValue index json


index : Decoder Index
index =
    (dict (list file))


file : Decoder File
file =
    decode File
        |> required "file_id" string
        |> required "path" string
        |> required "software_type" softwareType
        |> required "size" int
        |> required "inserted_at" date
        |> required "updated_at" date


softwareType : Decoder SoftwareType
softwareType =
    string |> andThen decodeSoftwareType


decodeSoftwareType : String -> Decoder SoftwareType
decodeSoftwareType str =
    case str of
        "text" ->
            succeed Text

        "cracker" ->
            succeed Cracker

        "exploit" ->
            succeed Exploit

        "firewall" ->
            succeed Firewall

        "hasher" ->
            succeed Hasher

        "log_forger" ->
            succeed LogForger

        "log_recover" ->
            succeed LogRecover

        "encryptor" ->
            succeed Encryptor

        "decryptor" ->
            succeed Decryptor

        "anymap" ->
            succeed AnyMap

        error ->
            fail <|
                "Trying to decode software_type, but value "
                    ++ toString error
                    ++ " is not supported."
