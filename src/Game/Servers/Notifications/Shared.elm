module Game.Servers.Notifications.Shared exposing (..)

import Game.Meta.Types.Network as Network exposing (NIP)
import Game.Servers.Filesystem.Shared as Filesystem


type Content
    = Generic Title Message
    | DownloadStarted NIP StorageId Filesystem.FileEntry
    | DownloadConcluded NIP StorageId Filesystem.FileEntry
    | UploadStarted NIP StorageId Filesystem.FileEntry
    | UploadConcluded NIP StorageId Filesystem.FileEntry
    | BruteforceStarted NIP
    | BruteforceConcluded NIP


type alias Title =
    String


type alias Message =
    String


type alias StorageId =
    String


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


renderToast : Content -> ( String, String )
renderToast =
    render
