module Game.Servers.Processes.Update exposing (..)

import Utils exposing (andThenWithDefault)
import Core.Messages exposing (CoreMsg)
import Game.Models exposing (GameModel)
import Game.Messages exposing (GameMsg(..))
import Game.Servers.Processes.Messages exposing (Msg(..))
import Game.Servers.Processes.Models
    exposing
        ( Processes
        , getProcessByID
        , pauseProcess
        , resumeProcess
        , removeProcess
        , addProcess
        )
import Game.Servers.Processes.ResultHandler exposing (completeProcess)


update :
    Msg
    -> Processes
    -> GameModel
    -> ( Processes, Cmd GameMsg, List CoreMsg )
update msg model game =
    case msg of
        Pause pID ->
            let
                processes_ =
                    andThenWithDefault
                        (\process ->
                            pauseProcess model process
                        )
                        model
                        (getProcessByID pID model)
            in
                ( processes_, Cmd.none, [] )

        Resume pID ->
            let
                processes_ =
                    andThenWithDefault
                        (\process ->
                            resumeProcess model process
                        )
                        model
                        (getProcessByID pID model)
            in
                ( processes_, Cmd.none, [] )

        Complete pID ->
            let
                ( processes_, feedback ) =
                    andThenWithDefault
                        (\process ->
                            completeProcess model process
                        )
                        ( model, [] )
                        (getProcessByID pID model)
            in
                ( processes_, Cmd.none, feedback )

        Remove pID ->
            let
                processes_ =
                    andThenWithDefault
                        (\process ->
                            removeProcess model process
                        )
                        model
                        (getProcessByID pID model)
            in
                ( processes_, Cmd.none, [] )

        Create process ->
            let
                processes_ =
                    addProcess
                        process
                        model
            in
                ( processes_, Cmd.none, [] )
