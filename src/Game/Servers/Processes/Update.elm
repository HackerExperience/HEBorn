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
        , completeProcess
        , removeProcess
        )


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
                processes_ =
                    andThenWithDefault
                        (\process ->
                            completeProcess model process
                        )
                        model
                        (getProcessByID pID model)
            in
                ( processes_, Cmd.none, [] )

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
