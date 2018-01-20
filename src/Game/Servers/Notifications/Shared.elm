module Game.Servers.Notifications.Shared exposing (..)

import Game.Meta.Types.Network exposing (NIP)
import Game.Servers.Filesystem.Shared as Filesystem


type Content
    = Generic Title Message
    | DownloadStarted NIP StorageId Filesystem.FileEntry
    | DownloadConcluded NIP StorageId Filesystem.FileEntry


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



-- it might make sense to return html instead


renderToast : Content -> ( String, String )
renderToast content =
    case content of
        Generic title body ->
            ( title, body )

        DownloadStarted origin storage fileEntry ->
            ( "Download started"
            , ((Filesystem.getName <| Filesystem.toFile fileEntry)
                ++ " download has started!"
              )
            )

        DownloadConcluded origin storage fileEntry ->
            ( "Download concluded"
            , ((Filesystem.getName <| Filesystem.toFile fileEntry)
                ++ " download has  concluded!"
              )
            )
