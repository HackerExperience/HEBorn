module Game.Servers.Processes.Update exposing (..)

import Game.Models as Game
import Game.Messages as Game
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
import Core.Dispatch as Dispatch exposing (Dispatch)


update :
    Msg
    -> Processes
    -> Game.Model
    -> ( Processes, Cmd Game.Msg, Dispatch )
update msg model game =
    case msg of
        Pause pID ->
            let
                processes_ =
                    pID
                        |> (flip getProcessByID) model
                        |> Maybe.map (pauseProcess model)
                        |> Maybe.withDefault model
            in
                ( processes_, Cmd.none, Dispatch.none )

        Resume pID ->
            let
                processes_ =
                    pID
                        |> (flip getProcessByID) model
                        |> Maybe.map (resumeProcess model)
                        |> Maybe.withDefault model
            in
                ( processes_, Cmd.none, Dispatch.none )

        Complete pID ->
            let
                ( processes_, feedback ) =
                    pID
                        |> (flip getProcessByID) model
                        |> Maybe.map (completeProcess model)
                        |> Maybe.withDefault ( model, Dispatch.none )
            in
                ( processes_, Cmd.none, feedback )

        Remove pID ->
            let
                processes_ =
                    pID
                        |> (flip getProcessByID) model
                        |> Maybe.map (removeProcess model)
                        |> Maybe.withDefault model
            in
                ( processes_, Cmd.none, Dispatch.none )

        Create process ->
            let
                processes_ =
                    addProcess
                        process
                        model
            in
                ( processes_, Cmd.none, Dispatch.none )
