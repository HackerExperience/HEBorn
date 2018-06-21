module Game.Servers.Filesystem.Models
    exposing
        ( Model
        , Files
        , Folders
        , initialModel
        , insertFile
        , insertFolder
        , deleteFile
        , deleteFolder
        , moveFile
        , renameFile
        , list
        , scan
        , getFile
        , getFolder
        , isFile
        , isFolder
        )

{-| Armazena pastas e arquivos de uma Storage.
-}

import Dict exposing (Dict)
import Game.Servers.Filesystem.Shared exposing (..)


{-| Model do Filesystem.

Arquivos são armazenados no campo files, pastas no campo folders.

Não é o método mais rápido ou simples, mas é o método mais fácil de explicar.

-}
type alias Model =
    { files : Files
    , folders : Folders
    }


{-| Dict de arquivos, todos os dados dos arquivos são armazenados utilizando
este tipo.
-}
type alias Files =
    Dict Id File


{-| Dict de pastas e arquivos dentro dessas pastas.
-}
type alias Folders =
    Dict StringPath (List Id)


{-| Obtida ao transformar um Path em String.
-}
type alias StringPath =
    String



-- crud


{-| Model inicial, só contem a pasta raiz.
-}
initialModel : Model
initialModel =
    { files = Dict.empty
    , folders = Dict.fromList [ ( "", [] ) ]
    }


{-| Insere um arquivo no filesystem, a localização do arquivo é definida pela
propriedade Path do mesmo.
-}
insertFile : Id -> File -> Model -> Model
insertFile id file ({ files, folders } as model) =
    let
        path =
            getPath file

        noFileExists =
            file
                |> getFullpath
                |> flip isFile model
                |> not
    in
        -- só inserir o arquivo caso o fullpath esteja livre
        if noFileExists then
            let
                -- deletear este arquivo da model caso ele já exista em outro
                -- diretório
                model_ =
                    deleteFile id model
            in
                -- inserir este arquivo no dict de arquivos e no dict de pastas
                { model_
                    | files = Dict.insert id file files
                    , folders = insertInFolder id path folders
                }
        else
            -- não fazer nada caso o fullpath esteja ocupado
            model


{-| Insere uma pasta dentro do Path.
-}
insertFolder : Path -> Name -> Model -> Model
insertFolder path name ({ folders } as model) =
    if isFolder path model then
        let
            fullpath =
                path
                    |> appendPath name
                    |> joinPath
        in
            -- não fazer nada caso já exista uma pasta no local
            case Dict.get fullpath folders of
                Just _ ->
                    model

                Nothing ->
                    { model | folders = Dict.insert fullpath [] folders }
    else
        model


{-| Deleta arquivo pelo Id.
-}
deleteFile : Id -> Model -> Model
deleteFile id ({ files, folders } as model) =
    case Dict.get id files of
        Just file ->
            { model
                | files = Dict.remove id files
                , folders = removeFromFolder id file.path folders
            }

        Nothing ->
            model


{-| Deleta uma pasta e seu conteúdo a partir de um Path.
-}
deleteFolder : Path -> Model -> Model
deleteFolder path ({ folders } as model) =
    if List.isEmpty <| scan path model then
        { model | folders = Dict.remove (joinPath path) folders }
    else
        model


{-| Move o arquivo para o Path.
-}
moveFile : Id -> Path -> Model -> Model
moveFile id path ({ files, folders } as model) =
    case Dict.get id files of
        Just file ->
            let
                file_ =
                    { file | path = path }

                files_ =
                    Dict.insert id file_ files

                folders_ =
                    folders
                        |> removeFromFolder id file.path
                        |> insertInFolder id file_.path
            in
                { model | files = files_, folders = folders_ }

        Nothing ->
            model


{-| Renomeia o arquivo.
-}
renameFile : Id -> Name -> Model -> Model
renameFile id name model =
    case getFile id model of
        Just file ->
            insertFile id (setName name file) model

        Nothing ->
            model



-- listing path contents


{-| List direct entries of given folder.
-}
list : Path -> Model -> List Entry
list path model =
    -- TODO: add nested folder support
    let
        -- remove uma área do p
        drop =
            String.dropLeft (String.length (joinPath path))

        -- não, não dá pra usar o toPath no lugar dessa função
        split =
            String.split "/"

        --
        filterer item =
            case item of
                FileEntry _ file ->
                    -- verificar
                    file.path == path

                FolderEntry path _ ->
                    let
                        -- checa se a pasta está vazia
                        isEmpty =
                            model
                                |> getFolder path
                                |> Maybe.map List.isEmpty
                                |> Maybe.withDefault True
                    in
                        if isEmpty then
                            True
                        else
                            -- caso a pasta não esteja vazia, verificar se
                            -- ela é um membro direto de path
                            path
                                |> joinPath
                                |> drop
                                |> split
                                |> List.length
                                |> ((==) 1)
    in
        List.filter filterer <| scan path model


{-| Lista conteúdo do do path.
-}
scan : Path -> Model -> List Entry
scan path model =
    let
        location =
            joinPath path

        -- uma função que checa se a string contém location
        contains =
            String.contains location

        -- é exatamente como o getFile, mas retorna com o id junto da file
        get id =
            case getFile id model of
                Just file ->
                    Just ( id, file )

                Nothing ->
                    Nothing

        -- uma função que filtra e mapeia arquivos que contenham location em
        -- seu path
        filterer id file =
            if (contains (joinPath file.path)) then
                Just <| FileEntry id file
            else
                Nothing

        path_ =
            parentPath path

        name =
            pathBase path

        -- reducer que passa por todas as pastas do jogo
        reducer currentPath files entries =
            -- caso a pasta atual contenha location
            if (contains currentPath) then
                let
                    --filtra arquivos desta pasta
                    entries1 =
                        List.filterMap
                            (get >> Maybe.andThen (uncurry filterer))
                            files

                    entries2 =
                        let
                            myPath =
                                toPath currentPath
                        in
                            if currentPath == location then
                                -- incluir este path nos entries caso ele seja
                                -- a location
                                entries1
                            else
                                -- incluir este path nos entries caso ele não
                                -- seja a location
                                myPath
                                    |> pathBase
                                    |> FolderEntry (parentPath myPath)
                                    |> flip (::) entries1
                in
                    List.append entries2 entries
            else
                -- caso a pasta atual não contenha location
                entries
    in
        Dict.foldl reducer [] model.folders



-- getters/setters


{-| Tenta coletar os dados do arquivo a partir do Id.
-}
getFile : Id -> Model -> Maybe File
getFile id =
    .files >> Dict.get id


{-| Tenta coletar a lista de Id de arquivos da pasta de tal Path.
-}
getFolder : Path -> Model -> Maybe (List Id)
getFolder path =
    .folders >> Dict.get (joinPath path)



-- checking operations


{-| Checa se um Path pertence a um arquivo.
-}
isFile : Path -> Model -> Bool
isFile fullpath { files, folders } =
    let
        path =
            parentPath fullpath

        name =
            pathBase fullpath
    in
        folders
            |> Dict.get (joinPath path)
            |> Maybe.withDefault []
            -- filtrar da lista de id de arquivos no path...
            |> List.filter
                -- ...pegando os dados para dos arquivos de cada id
                (flip Dict.get files
                    >> Maybe.map getName
                    -- resulta em True caso o nome do arquivo seja igual ao do
                    -- fullpath
                    >> Maybe.map ((==) name)
                    -- converte o Nothing em False
                    >> Maybe.withDefault False
                )
            -- o fullpath não pertence a um arquivo caso a lista filtrada
            -- esteja vazia
            |> List.isEmpty
            |> not


{-| Checa se um Path pertence a uma pasta.
-}
isFolder : Path -> Model -> Bool
isFolder path model =
    case getFolder path model of
        Just _ ->
            True

        Nothing ->
            False



-- internals


{-| Tenta remover arquivo de tais Folders.
-}
removeFromFolder : Id -> Path -> Folders -> Folders
removeFromFolder id path folders =
    let
        location =
            joinPath path
    in
        -- não fazer nada caso a pasta não exista
        case Dict.get location folders of
            Just ids ->
                ids
                    |> List.filter ((/=) id)
                    |> flip (Dict.insert location) folders

            Nothing ->
                folders


{-| WIP
-}
insertInFolder : Id -> Path -> Folders -> Folders
insertInFolder id path folders =
    let
        location =
            joinPath path
    in
        folders
            |> Dict.get location
            |> Maybe.withDefault []
            |> (::) id
            |> flip (Dict.insert location) folders
