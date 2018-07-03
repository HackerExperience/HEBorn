module Game.Servers.Notifications.Shared exposing (..)

import Game.Meta.Types.Network as Network exposing (NIP)
import Game.Servers.Filesystem.Shared as Filesystem


{-| Conteúdo de uma notificação:

    - `Generic`

Notifiação genérica.

    - `DownloadStarted`

Notificação de download iniciado.

    - `DownloadConcluded`

Notificação de download concluído.

    - `UploadStarted`

Notificação de upload iniciado.

    - `UploadConcluded`

Notificação de upload concluído.

    - `BruteforceStarted`

Notificação de bruteforce iniciado.

    - `BruteforceConcluded`

notificação de bruteforce concluído.

-}
type Content
    = Generic Title Message
    | DownloadStarted NIP StorageId Filesystem.FileEntry
    | DownloadConcluded NIP StorageId Filesystem.FileEntry
    | UploadStarted NIP StorageId Filesystem.FileEntry
    | UploadConcluded NIP StorageId Filesystem.FileEntry
    | BruteforceStarted NIP
    | BruteforceConcluded NIP


{-| Título de uma notificação.
-}
type alias Title =
    String


{-| Mensagem de uma notificação.
-}
type alias Message =
    String


{-| Storage de uma notificação.
-}
type alias StorageId =
    String


{-| Formata conteúdo da notificação em duas strings, uma com um resumo da
notificação e outra com a notificação completa.
-}
render : Content -> ( String, String )
render content =
    case content of
        Generic title body ->
            ( title, body )

        DownloadStarted origin storage fileEntry ->
            ( "New download started"
            , ((Filesystem.getName <| Filesystem.toFile fileEntry)
                ++ " download started!"
              )
            )

        DownloadConcluded origin storage fileEntry ->
            ( "New download concluded"
            , ((Filesystem.getName <| Filesystem.toFile fileEntry)
                ++ " download concluded!"
              )
            )

        UploadStarted origin storage fileEntry ->
            ( "New upload started"
            , ((Filesystem.getName <| Filesystem.toFile fileEntry)
                ++ " upload started!"
              )
            )

        UploadConcluded origin storage fileEntry ->
            ( "New upload concluded"
            , ((Filesystem.getName <| Filesystem.toFile fileEntry)
                ++ " upload concluded!"
              )
            )

        BruteforceStarted target ->
            ( "Bruteforce started"
            , "Trying to crack " ++ (Network.render target)
            )

        BruteforceConcluded target ->
            ( "Bruteforce concluded"
            , "Finished cracking " ++ (Network.render target)
            )


{-| O mesmo que render, mas com outro nome. (?)
-}
renderToast : Content -> ( String, String )
renderToast =
    render
