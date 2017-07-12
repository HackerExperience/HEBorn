module Game.Servers.Filesystem.Update exposing (..)

import Game.Models as Game
import Game.Messages as Game
import Game.Servers.Filesystem.Messages exposing (Msg(..))
import Game.Servers.Filesystem.Models exposing (..)
import Core.Dispatch as Dispatch exposing (Dispatch)


update :
    Game.Model
    -> Msg
    -> Filesystem
    -> ( Filesystem, Cmd Game.Msg, Dispatch )
update game msg model =
    case msg of
        Delete fID ->
            let
                file =
                    getFileById model fID

                model_ =
                    case file of
                        Just file ->
                            removeFile file model

                        Nothing ->
                            model
            in
                ( model_, Cmd.none, Dispatch.none )

        CreateTextFile fPath fName ->
            let
                file =
                    (StdFile
                        (StdFileData
                            ("tempID"
                                ++ "_TXT_"
                                ++ (fPath ++ "/" ++ fName ++ "_")
                                ++ (toString game.meta.lastTick)
                            )
                            fName
                            "txt"
                            (FileVersionNumber 1)
                            (FileSizeNumber 0)
                            fPath
                            []
                        )
                    )

                model_ =
                    addFile file model
            in
                ( model_, Cmd.none, Dispatch.none )

        CreateEmptyDir fPath fName ->
            let
                file =
                    (Folder
                        (FolderData
                            ("tempID"
                                ++ "_DIR_"
                                ++ (fPath ++ "/" ++ fName ++ "_")
                                ++ (toString game.meta.lastTick)
                            )
                            fName
                            fPath
                        )
                    )

                model_ =
                    addFile file model
            in
                ( model_, Cmd.none, Dispatch.none )

        Move fID fPath ->
            let
                model_ =
                    getFileById model fID
                        |> Maybe.map (\file -> moveFile fPath file model)
                        |> Maybe.withDefault model
            in
                ( model_, Cmd.none, Dispatch.none )

        Rename fID fName ->
            let
                model_ =
                    getFileById model fID
                        |> Maybe.map (\file -> renameFile fName file model)
                        |> Maybe.withDefault model
            in
                ( model_, Cmd.none, Dispatch.none )
