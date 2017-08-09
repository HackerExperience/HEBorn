module Game.Servers.Filesystem.Update exposing (update)

import Game.Models as Game
import Game.Servers.Filesystem.Messages exposing (Msg(..))
import Game.Servers.Filesystem.Shared exposing (..)
import Game.Servers.Filesystem.Models exposing (..)
import Core.Dispatch as Dispatch exposing (Dispatch)


type alias UpdateResponse =
    ( Filesystem, Cmd Msg, Dispatch )


update :
    Game.Model
    -> Msg
    -> Filesystem
    -> UpdateResponse
update game msg model =
    case msg of
        Delete fID ->
            delete fID model

        CreateTextFile path ->
            createTextFile path
                (toString game.meta.lastTick)
                model

        CreateEmptyDir path ->
            createEmptyDir path
                (toString game.meta.lastTick)
                model

        Move fID fLoc ->
            move fID fLoc model

        Rename fID fBaseName ->
            rename fID fBaseName model



-- INTERNALS


delete : FileID -> Filesystem -> UpdateResponse
delete fID model =
    let
        file =
            getEntry fID model

        model_ =
            case file of
                Just file ->
                    deleteEntry file model

                Nothing ->
                    model
    in
        ( model_, Cmd.none, Dispatch.none )


createTextFile : FilePath -> String -> Filesystem -> UpdateResponse
createTextFile ( fLoc, fBaseName ) uId model =
    let
        model_ =
            model
                |> locationToParentRef fLoc
                |> Maybe.map
                    (\path ->
                        FileEntry
                            { id =
                                "tempID"
                                    ++ "_TXT_"
                                    ++ (fBaseName ++ "_")
                                    ++ uId
                            , name = fBaseName
                            , extension = "txt"
                            , version = Nothing
                            , size = Just 0
                            , parent = path
                            , modules = []
                            }
                    )
                |> Maybe.map (\e -> addEntry e model)
                |> Maybe.withDefault model
    in
        ( model_, Cmd.none, Dispatch.none )


createEmptyDir : FilePath -> String -> Filesystem -> UpdateResponse
createEmptyDir ( fLoc, fName ) uId model =
    let
        model_ =
            model
                |> locationToParentRef fLoc
                |> Maybe.map
                    (\path ->
                        FolderEntry
                            { id =
                                "tempID"
                                    ++ "_DIR_"
                                    ++ (fName ++ "_")
                                    ++ uId
                            , name = fName
                            , parent = path
                            }
                    )
                |> Maybe.map (\e -> addEntry e model)
                |> Maybe.withDefault model
    in
        ( model_, Cmd.none, Dispatch.none )


move : FileID -> Location -> Filesystem -> UpdateResponse
move fID fLoc model =
    let
        model_ =
            model
                |> getEntry fID
                |> Maybe.map
                    (\e ->
                        moveEntry
                            ( fLoc, getEntryBasename e )
                            e
                            model
                    )
                |> Maybe.withDefault model
    in
        ( model_, Cmd.none, Dispatch.none )


rename : FileID -> String -> Filesystem -> UpdateResponse
rename fID fBaseName model =
    let
        model_ =
            model
                |> getEntry fID
                |> Maybe.map
                    (\e ->
                        moveEntry
                            ( getEntryLocation e model
                            , fBaseName
                            )
                            e
                            model
                    )
                |> Maybe.withDefault model
    in
        ( model_, Cmd.none, Dispatch.none )
