module Game.Servers.Filesystem.Update exposing (..)

import Game.Models as Game
import Game.Messages as Game
import Game.Servers.Filesystem.Messages exposing (Msg(..))
import Game.Servers.Filesystem.Shared exposing (..)
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
                    getEntry fID model

                model_ =
                    case file of
                        Just file ->
                            deleteEntry file model

                        Nothing ->
                            model
            in
                ( model_, Cmd.none, Dispatch.none )

        CreateTextFile ( fLoc, fBaseName ) ->
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
                                            ++ (toString game.meta.lastTick)
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

        CreateEmptyDir ( fLoc, fName ) ->
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
                                            ++ (toString game.meta.lastTick)
                                    , name = fName
                                    , parent = path
                                    }
                            )
                        |> Maybe.map (\e -> addEntry e model)
                        |> Maybe.withDefault model
            in
                ( model_, Cmd.none, Dispatch.none )

        Move fID fLoc ->
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

        Rename fID fBaseName ->
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
