module Game.Servers.Filesystem.Shared
    exposing
        ( Id
        , File
        , Path
        , Name
        , Extension
        , Version
        , Size
        , Entry(..)
        , FileEntry
        , Type(..)
        , CrackerModules
        , FirewallModules
        , ExploitModules
        , HasherModules
        , LogForgerModules
        , LogRecoverModules
        , EncryptorModules
        , DecryptorModules
        , AnyMapModules
        , SpywareModules
        , toPath
        , joinPath
        , pathBase
        , parentPath
        , appendPath
        , concatPath
        , getName
        , setName
        , getExtension
        , getPath
        , setPath
        , getFullpath
        , getSize
        , getType
        , getMeanVersion
        , getModuleVersion
        , getEntryName
        , isValidFilename
        , isFolderEntry
        , hasModules
        , toId
        , toFile
        , toFileEntry
        )

{-| Estruturas de dados utilizadas pelo Filesystem e por outros que utilizam
o Filesystem.
-}

import Utils.List as List


{-| O id do arquivo.
-}
type alias Id =
    String


{-| Dados do arquivo, como nome, extenção, caminho, tamanho e tipo.
-}
type alias File =
    { name : Name
    , extension : Extension
    , path : Path
    , size : Size
    , type_ : Type
    }


{-| Usado para realizar ações genéricas em arquivos e pastas.
-}
type Entry
    = FileEntry Id File
    | FolderEntry Path String


{-| Caminho para alguma coisa, geralmente utilizado com pastas, mas é usado
para localizar arquivos também
-}
type alias Path =
    List Name


{-| Nome de um arquivo ou pasta.
-}
type alias Name =
    String


{-| Extenção de uma pasta.
-}
type alias Extension =
    String


{-| Tamanho de um arquivo.
-}
type alias Size =
    Int


{-| Usado para passar o conteúdo de um arquivo junto de seu id.
-}
type alias FileEntry =
    ( Id, File )


{-| Versão de um arquivo, nota: a versão de um arquivo só é computada quando
necessário.
-}
type alias Version =
    Float


{-| Tipos de arquivo, arquivos que forem software também incluem seus módulos.

  - CryptoKey: chave de criptografia de um arquivo, dá acesso a arquivos
    criptografados
  - Cracker: rouba senha de um servidor
  - Firewall: protege o servidor de exploits
  - Exploit: invade servidor por meio de uma conexão existente, como FTP ou
    SSH
  - Hasher: protege o servidor e um cracker
  - LogForger: cria versões falsas de um log
  - LogRecover: recupera busca logs desconhecidos e versões antigas logs
    conhecidos
  - Encryptor: usado para criptografar logs
  - Decryptor: usado para descriptografar logs
  - AnyMap: usado para mapear a rede
  - Spyware: gera dinheiro vendendo dados do servidor

-}
type Type
    = Text
    | CryptoKey
    | Cracker CrackerModules
    | Firewall FirewallModules
    | Exploit ExploitModules
    | Hasher HasherModules
    | LogForger LogForgerModules
    | LogRecover LogRecoverModules
    | Encryptor EncryptorModules
    | Decryptor DecryptorModules
    | AnyMap AnyMapModules
    | Spyware SpywareModules


{-| O mínimo que um record precisa ter para ser considerado um módulo.
-}
type alias Module a =
    { a | version : Float }


{-| Módulo que só tem versão.
-}
type alias SimpleModule =
    { version : Float }


{-| Módulos para o tipo de software `Cracker`.
-}
type alias CrackerModules =
    { bruteForce : SimpleModule
    , overFlow : SimpleModule
    }


{-| Módulos para o tipo de software `Firewall`.
-}
type alias FirewallModules =
    { active : SimpleModule
    , passive : SimpleModule
    }


{-| Módulos para o tipo de software `Exploit`.
-}
type alias ExploitModules =
    { ftp : SimpleModule
    , ssh : SimpleModule
    }


{-| Módulos para o tipo de software `Hasher`.
-}
type alias HasherModules =
    { password : SimpleModule
    }


{-| Módulos para o tipo de software `LogForger`.
-}
type alias LogForgerModules =
    { create : SimpleModule
    , edit : SimpleModule
    }


{-| Módulos para o tipo de software `LogRecover`.
-}
type alias LogRecoverModules =
    { recover : SimpleModule
    }


{-| Módulos para o tipo de software `Encryptor`.
-}
type alias EncryptorModules =
    { file : SimpleModule
    , log : SimpleModule
    , connection : SimpleModule
    , process : SimpleModule
    }


{-| Módulos para o tipo de software `Decryptor`.
-}
type alias DecryptorModules =
    { file : SimpleModule
    , log : SimpleModule
    , connection : SimpleModule
    , process : SimpleModule
    }


{-| Módulos para o tipo de software `AnyMap`.
-}
type alias AnyMapModules =
    { geo : SimpleModule
    , net : SimpleModule
    }


{-| Módulos para o tipo de software `Spyware`.
-}
type alias SpywareModules =
    { spy : SimpleModule
    }



-- path operations


{-| Converte uma String em um Path.
-}
toPath : String -> Path
toPath path =
    case String.split "/" path of
        "" :: path ->
            "" :: path

        path ->
            "" :: path


{-| Converte uma Path em um String.
-}
joinPath : Path -> String
joinPath path =
    case path of
        "" :: _ ->
            String.join "/" path

        _ ->
            "/" ++ (String.join "/" path)


{-| Pega o último elemento de um Path.
-}
pathBase : Path -> Name
pathBase path =
    case List.head <| List.reverse path of
        Just a ->
            a

        Nothing ->
            ""


{-| Remove o último elemento de um Path.
-}
parentPath : Path -> Path
parentPath =
    List.dropRight 1


{-| Insere um elemento no final de um um Path.
-}
appendPath : Name -> Path -> Path
appendPath name path =
    -- add root folder if not present
    path ++ [ name ]


{-| Concatena vários paths.
-}
concatPath : List Path -> Path
concatPath =
    List.concat



-- getters/setters


{-| Pega o `Name` de um arquivo.
-}
getName : File -> Name
getName =
    .name


{-| Seta o `Name` de um arquivo.
-}
setName : String -> File -> File
setName name file =
    { file | name = name }


{-| Pega a `Extension` de um arquivo.
-}
getExtension : File -> Extension
getExtension =
    .extension


{-| Pega o `Path` da pasta aonde o arquivo está.
-}
getPath : File -> Path
getPath =
    .path


{-| Seta o `Path` de um arquivo.
-}
setPath : Path -> File -> File
setPath path file =
    { file | path = path }


{-| Pega o `Path` completo de um arquivo (inclui o nome do arquivo no path).
-}
getFullpath : File -> Path
getFullpath file =
    file
        |> getPath
        |> appendPath (getName file)


{-| Pega o `Size` de um arquivo.
-}
getSize : File -> Size
getSize =
    .size


{-| Pega o `Type` de um arquivo.
-}
getType : File -> Type
getType =
    .type_


{-| Pega a versão média de um arquivo, retorna Maybe pois o arquivo pode não
ser um software.
-}
getMeanVersion : File -> Maybe Version
getMeanVersion file =
    case getModuleVersions file of
        Just versions ->
            versions
                |> List.foldl (+) 0.0
                |> flip (/) (toFloat <| List.length versions)
                |> Just

        Nothing ->
            Nothing


{-| Pega a versão de um módulo.
-}
getModuleVersion : Module a -> Version
getModuleVersion =
    .version


{-| Pega o nome de um `Entry`.
-}
getEntryName : Entry -> Name
getEntryName entry =
    case entry of
        FolderEntry _ name ->
            name

        FileEntry _ file ->
            getName file



-- checking operations


{-| Checa se uma `String` é valida como nome de arquivo.
-}
isValidFilename : String -> Bool
isValidFilename filename =
    -- TODO: Add special characters & entire name validation
    if String.length filename > 0 then
        False
    else if String.length filename < 255 then
        False
    else
        True


{-| Checa se uma `Entry` é uma pasta.
-}
isFolderEntry : Entry -> Bool
isFolderEntry entry =
    case entry of
        FolderEntry _ _ ->
            True

        FileEntry _ _ ->
            False


{-| Checa se um `File` é um software (tem módulos).
-}
hasModules : File -> Bool
hasModules file =
    case getType file of
        Text ->
            False

        CryptoKey ->
            False

        _ ->
            True



-- entry convertion


{-| Coleta o Id de um `FileEntry`.
-}
toId : FileEntry -> Id
toId =
    Tuple.first


{-| Coleta o `File` de um `FileEntry`.
-}
toFile : FileEntry -> File
toFile =
    Tuple.second


{-| Tenta converter um `Entry` em um `FileEntry`.
-}
toFileEntry : Entry -> Maybe FileEntry
toFileEntry entry =
    case entry of
        FolderEntry _ _ ->
            Nothing

        FileEntry id file ->
            Just ( id, file )



-- internals


{-| Tenta coletar a versão de todos os módulos, utilizado para calcular a
versão média.
-}
getModuleVersions : File -> Maybe (List Version)
getModuleVersions file =
    case getType file of
        Text ->
            Nothing

        CryptoKey ->
            Nothing

        Cracker { bruteForce, overFlow } ->
            Just [ bruteForce.version, overFlow.version ]

        Firewall { active, passive } ->
            Just [ active.version, passive.version ]

        Exploit { ftp, ssh } ->
            Just [ ftp.version, ssh.version ]

        Hasher { password } ->
            Just [ password.version ]

        LogForger { create, edit } ->
            Just [ create.version, edit.version ]

        LogRecover { recover } ->
            Just [ recover.version ]

        Encryptor { file, log, connection, process } ->
            Just
                [ file.version
                , log.version
                , connection.version
                , process.version
                ]

        Decryptor { file, log, connection, process } ->
            Just
                [ file.version
                , log.version
                , connection.version
                , process.version
                ]

        AnyMap { geo, net } ->
            Just [ geo.version, net.version ]

        Spyware { spy } ->
            Just [ spy.version ]
