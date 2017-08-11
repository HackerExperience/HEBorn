module Game.Servers.Logs.Models
    exposing
        ( Model
        , ID
        , Log
        , Content(..)
        , Data
        , Status(..)
        , Format(..)
        , LocalLogin
        , RemoteLogin
        , Connection
        , Download
        , FileName
        , ServerUser
        , Render(..)
        , initialModel
        , new
        , insert
        , remove
        , member
        , get
        , filter
        , getTimestamp
        , getContent
        , setTimestamp
        , setContent
          -- TODO: Hide / UnHide
        , render
        )

import Dict exposing (Dict)
import Time exposing (Time)
import Game.Network.Types exposing (IP, NIP)


type alias Model =
    Dict ID Log


type alias ID =
    String


type alias Log =
    { timestamp : Time
    , status : Status
    , content : Content
    }


type Content
    = Uncrypted Data
    | Encrypted


type alias Data =
    { raw : String
    , format : Maybe Format
    }


type Status
    = Normal
    | RecentlyFound
    | RecentlyCreated


type Format
    = LocalLoginFormat LocalLogin
    | RemoteLoginFormat RemoteLogin
    | ConnectionFormat Connection
    | DownloadByFormat Download
    | DownloadFromFormat Download


type alias LocalLogin =
    { from : IP
    , user : ServerUser
    }


type alias RemoteLogin =
    { into : IP
    }


type alias Connection =
    { nip : IP
    , from : IP
    , to : IP
    }


type alias Download =
    { filename : FileName
    , nip : IP
    }


type alias FileName =
    String


type alias ServerUser =
    String


type
    Render
    -- TODO: this still's not as good as it should be
    = TextE String
    | NipE IP
    | SpecialE String String


initialModel : Model
initialModel =
    Dict.empty


new : Time -> Status -> Maybe String -> Log
new timestamp status content =
    content
        |> Maybe.map (parseData >> Uncrypted)
        |> Maybe.withDefault Encrypted
        |> Log timestamp status


insert : ID -> Log -> Model -> Model
insert =
    Dict.insert


remove : ID -> Model -> Model
remove =
    Dict.remove


member : ID -> Model -> Bool
member =
    Dict.member


get : ID -> Model -> Maybe Log
get =
    Dict.get


filter : (ID -> Log -> Bool) -> Model -> Dict ID Log
filter =
    Dict.filter


getTimestamp : Log -> Time
getTimestamp =
    .timestamp


getContent : Log -> Content
getContent =
    .content


setTimestamp : Time -> Log -> Log
setTimestamp timestamp log =
    { log | timestamp = timestamp }


setContent : Maybe String -> Log -> Log
setContent newContent log =
    let
        content =
            case newContent of
                Just raw ->
                    Uncrypted <| parseData raw

                Nothing ->
                    Encrypted

        log_ =
            { log | content = content }
    in
        log_


render : Data -> List Render
render { format, raw } =
    case format of
        Just format ->
            case format of
                LocalLoginFormat { from, user } ->
                    [ NipE from
                    , TextE " logged in as "
                    , SpecialE "user" user
                    ]

                RemoteLoginFormat { into } ->
                    [ TextE "Logged into "
                    , NipE into
                    ]

                ConnectionFormat { nip, from, to } ->
                    [ NipE nip
                    , TextE " bounced connection from "
                    , NipE from
                    , TextE " to "
                    , NipE to
                    ]

                DownloadByFormat { filename, nip } ->
                    [ TextE "File "
                    , SpecialE "file" filename
                    , TextE " downloaded by "
                    , NipE nip
                    ]

                DownloadFromFormat { filename, nip } ->
                    [ TextE "File "
                    , SpecialE "file" filename
                    , TextE " downloaded from "
                    , NipE nip
                    ]

        Nothing ->
            [ TextE raw ]



-- internals


parseData : String -> Data
parseData raw =
    case String.split " " raw of
        [ addr, "logged", "in", "as", user ] ->
            LocalLogin addr user
                |> LocalLoginFormat
                |> Just
                |> Data raw

        [ "Logged", "into", addr ] ->
            RemoteLogin addr
                |> RemoteLoginFormat
                |> Just
                |> Data raw

        [ subj, "bounced", "connection", "from", from, "to", to ] ->
            Connection subj from to
                |> ConnectionFormat
                |> Just
                |> Data raw

        [ "File", file, "downloaded", "by", addr ] ->
            Download file addr
                |> DownloadByFormat
                |> Just
                |> Data raw

        [ "File", file, "downloaded", "from", addr ] ->
            Download file addr
                |> DownloadFromFormat
                |> Just
                |> Data raw

        _ ->
            Data raw Nothing
