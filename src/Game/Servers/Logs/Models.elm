module Game.Servers.Logs.Models exposing (..)

import Dict exposing (Dict)
import Time exposing (Time)
import Regex exposing (HowMany(All), regex)
import Game.Meta.Types.Network exposing (IP, NIP)


type alias Model =
    { logs : Dict ID Log
    , drawOrder : Dict Date ID
    }


type alias ID =
    String


type alias Date =
    ( Time, Int )


type alias Log =
    { timestamp : Time
    , status : Status
    , content : Content
    }


type Content
    = NormalContent Data
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


initialModel : Model
initialModel =
    { logs = Dict.empty
    , drawOrder = Dict.empty
    }


new : Time -> Status -> Maybe String -> Log
new timestamp status content =
    content
        |> Maybe.map (dataFromString >> NormalContent)
        |> Maybe.withDefault Encrypted
        |> Log timestamp status


insert : ID -> Log -> Model -> Model
insert id log model =
    { model
        | logs = Dict.insert id log model.logs
        , drawOrder =
            Dict.insert
                (findId ( log.timestamp, 0 ) model.drawOrder)
                id
                model.drawOrder
    }


findId : ( Time, Int ) -> Dict Date ID -> Date
findId (( birth, from ) as pig) model =
    model
        |> Dict.get pig
        |> Maybe.map (\twin -> findId ( birth, from + 1 ) model)
        |> Maybe.withDefault pig


remove : ID -> Model -> Model
remove id model =
    { model
        | logs = Dict.remove id model.logs
        , drawOrder = searchAndDestroy 0 id model
    }


searchAndDestroy : Int -> ID -> Model -> Dict Date ID
searchAndDestroy n id model =
    if n < 99 then
        case get id model of
            Just log ->
                case Dict.get ( log.timestamp, n ) model.drawOrder of
                    Just candidate ->
                        if candidate == id then
                            Dict.remove ( log.timestamp, n ) model.drawOrder
                        else
                            searchAndDestroy (n + 1) id model

                    Nothing ->
                        searchAndDestroy (n + 1) id model

            Nothing ->
                searchAndDestroy (n + 1) id model
    else
        model.drawOrder


member : ID -> Model -> Bool
member id model =
    Dict.member id model.logs


get : ID -> Model -> Maybe Log
get id model =
    Dict.get id model.logs


filter : (ID -> Log -> Bool) -> Model -> Dict ID Log
filter filterer model =
    Dict.filter filterer model.logs


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
                    NormalContent <| dataFromString raw

                Nothing ->
                    Encrypted

        log_ =
            { log | content = content }
    in
        log_


dataFromString : String -> Data
dataFromString raw =
    Data raw <|
        case String.split " " raw of
            [ addr, "logged", "in", "as", user ] ->
                if (ipValid addr) then
                    LocalLogin addr user
                        |> LocalLoginFormat
                        |> Just
                else
                    Nothing

            [ "Logged", "into", addr ] ->
                if (ipValid addr) then
                    RemoteLogin addr
                        |> RemoteLoginFormat
                        |> Just
                else
                    Nothing

            [ subj, "bounced", "connection", "from", from, "to", to ] ->
                Connection subj from to
                    |> ConnectionFormat
                    |> Just

            [ "File", file, "downloaded", "by", addr ] ->
                if (ipValid addr) then
                    Download file addr
                        |> DownloadByFormat
                        |> Just
                else
                    Nothing

            [ "File", file, "downloaded", "from", addr ] ->
                if (ipValid addr) then
                    Download file addr
                        |> DownloadFromFormat
                        |> Just
                else
                    Nothing

            _ ->
                Nothing


ipValid : String -> Bool
ipValid src =
    Regex.find All
        (regex "^((?:\\d{1,3}\\.){3}\\d{1,3})$")
        src
        |> List.length
        |> flip (==) 1
