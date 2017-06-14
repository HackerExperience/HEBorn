module Game.Servers.Requests.FileIndex
    exposing
        ( Response(..)
        , request
        , receive
        )

import Dict exposing (Dict)
import Json.Decode
    exposing
        -- this request contains no payload, so no problems with importing this
        ( Decoder
        , decodeString
        , succeed
        , fail
        , andThen
        , list
        , dict
        , string
        , int
        )
import Json.Decode.Pipeline exposing (decode, required, hardcoded)
import Json.Encode as Encode
import Result exposing (Result(..))
import Core.Config exposing (Config)
import Game.Servers.Messages exposing (..)
import Requests.Requests as Requests
import Requests.Topics exposing (Topic(..))
import Requests.Types exposing (Code(..))


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

    -- , modules : {}
    -- , meta : {}
    -- , inserted_at : ?
    -- , updated_at : ?
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


request : Config -> Cmd ServerMsg
request =
    Requests.request ServerFileIndexTopic
        (FileIndexRequest >> Request)
        Nothing
        Encode.null


receive : Code -> String -> Response
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


decoder : String -> Result String Index
decoder json =
    decodeString index json


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

        error ->
            fail <|
                "Trying to decode software_type, but value "
                    ++ toString error
                    ++ " is not supported."
