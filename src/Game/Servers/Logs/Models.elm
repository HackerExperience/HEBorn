module Game.Servers.Logs.Models exposing (..)

{-| Logs são registros deixados num servidor após alguém interagir com o mesmo.
-}

import Dict exposing (Dict)
import Time exposing (Time)
import Regex exposing (HowMany(All), regex)
import Utils.Maybe as Maybe
import Game.Meta.Types.Network exposing (IP, NIP)


{-| A model contém Logs de um servidor e a ordem de desenho dos mesmos e a
ordem de desenho dos mesmos organizados por data.
-}
type alias Model =
    { logs : Dict ID Log
    , drawOrder : Dict Date ID
    }


{-| Id do log é uma simples string recebida do servidor
-}
type alias ID =
    String


{-| Usado para montar a ordem de desenho dos logs, este nome está confuso e
precisa ser mudado.
-}
type alias Date =
    ( Time, Int )


{-| Log é composto por um conjunto de dados:

  - timestamp

Data de criação do log.

  - status

Estado do log perante o jogador (recém descoberto, recém criado ou conhecido).

  - content

Conteúdo do log, indisponível quando o mesmo está criptografado.

-}
type alias Log =
    { timestamp : Time
    , status : Status
    , content : Content
    }


{-| O conteúdo dos Logs pode estar criptografado ou não.
-}
type Content
    = NormalContent Data
    | Encrypted


{-| Conteúdo de um Log quando o mesmo está descriptografado.
-}
type alias Data =
    { raw : String
    , format : Maybe Format
    }


{-| Status do log, utilizado para fazer highlight no logs novos.
-}
type Status
    = Normal
    | RecentlyFound
    | RecentlyCreated


{-| Formatos de logs conhecidos:

  - LocalLoginFormat

Login no servidor local.

  - RemoteLoginFormat

Login em servidor remoto.

  - ConnectionFormat

Conexão aberta entre dois servidores.

  - DownloadByFormat

Arquivo foi baixado por outro servidor.

  - DownloadFromFormat

Arquivo foi baixado de outro servidor.

-}
type Format
    = LocalLoginFormat LocalLogin
    | RemoteLoginFormat RemoteLogin
    | ConnectionFormat Connection
    | DownloadByFormat Download
    | DownloadFromFormat Download


{-| Dados de um Log de login local.
-}
type alias LocalLogin =
    { from : IP
    , user : ServerUser
    }


{-| Dados de um Log de login remoto.
-}
type alias RemoteLogin =
    { into : IP
    }


{-| Dados de um Log de conexão entre dois pontos.
-}
type alias Connection =
    { nip : IP
    , from : IP
    , to : IP
    }


{-| Dados de um Log de arquivo baixado.
-}
type alias Download =
    { filename : FileName
    , nip : IP
    }


{-| Nome de um arquivo.
-}
type alias FileName =
    String


{-| Usuáro de um servidor.
-}
type alias ServerUser =
    String


{-| Model inicial dos logs do servidor.
-}
initialModel : Model
initialModel =
    { logs = Dict.empty
    , drawOrder = Dict.empty
    }


{-| Cria um Log novo.
-}
new : Time -> Status -> Maybe String -> Log
new timestamp status content =
    content
        |> Maybe.map (dataFromString >> NormalContent)
        |> Maybe.withDefault Encrypted
        |> Log timestamp status


{-| Insere um Log, substitui log existente caso já exista algum.
-}
insert : ID -> Log -> Model -> Model
insert id log model =
    let
        logs =
            Dict.insert id log model.logs

        drawOrder =
            if Maybe.isNothing <| Dict.get id model.logs then
                Dict.insert
                    (findId ( log.timestamp, 0 ) model.drawOrder)
                    id
                    model.drawOrder
            else
                model.drawOrder
    in
        { model | logs = logs, drawOrder = drawOrder }


{-| Cria um Id para log novo.
O nome dessa função está misleading, é uma boa ideia mudar.
-}
findId : ( Time, Int ) -> Dict Date ID -> Date
findId (( birth, from ) as pig) model =
    model
        |> Dict.get pig
        |> Maybe.map (\twin -> findId ( birth, from + 1 ) model)
        |> Maybe.withDefault pig


{-| Remove Log por Id.
-}
remove : ID -> Model -> Model
remove id model =
    let
        logs =
            Dict.remove id model.logs

        drawOrder =
            searchAndDestroy 0 id model
    in
        { model | logs = logs, drawOrder = drawOrder }


{-| Remove um log da drawOrder usando o Id e um Int, que pode ser 0 caso
ele seja desconhecido.

Seria uma boa ideia inverter a ordem do Id e do Int e renomear esta função,
o nome está confuso.

-}
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


{-| Checa se Log é membro da Model.
-}
member : ID -> Model -> Bool
member id model =
    Dict.member id model.logs


{-| Tenta pegar Log.
-}
get : ID -> Model -> Maybe Log
get id model =
    Dict.get id model.logs


{-| Filtra logs da Model, retorna um dict com os logs filtrados.
-}
filter : (ID -> Log -> Bool) -> Model -> Dict ID Log
filter filterer model =
    Dict.filter filterer model.logs


{-| Pega a timestamp do Log.
-}
getTimestamp : Log -> Time
getTimestamp =
    .timestamp


{-| Pega o conteúdo do Log.
-}
getContent : Log -> Content
getContent =
    .content


{-| Atualiza a timestamp do Log, essa função está proposta para exclusão.
-}
setTimestamp : Time -> Log -> Log
setTimestamp timestamp log =
    { log | timestamp = timestamp }


{-| Atualiza o conteúdo do Log, esta função está proposta para exclusão.
-}
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


{-| Tenta converter o conteúdo de texto dos logs em um tipo de log conhecido.
-}
dataFromString : String -> Data
dataFromString raw =
    -- dividir a string em vários pedaços dentro de uma lista, para poder
    -- verificar seu formato com pattern match
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


{-| Checa se IP é válido.
-}
ipValid : String -> Bool
ipValid src =
    Regex.find All
        (regex "^((?:\\d{1,3}\\.){3}\\d{1,3})$")
        src
        |> List.length
        |> flip (==) 1
