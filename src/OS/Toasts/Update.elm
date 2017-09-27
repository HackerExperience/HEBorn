module OS.Toasts.Update exposing (update)

import Process
import Task
import Time exposing (Time)
import Utils.Update as Update
import Game.Data as Game
import Core.Dispatch as Dispatch exposing (Dispatch)
import OS.Toasts.Messages exposing (..)
import OS.Toasts.Models exposing (..)


type alias UpdateResponse =
    ( Model, Cmd Msg, Dispatch )


update :
    Game.Data
    -> Msg
    -> Model
    -> UpdateResponse
update _ msg model =
    case msg of
        Append new ->
            model
                |> insert new
                |> uncurry waitFade

        Remove id ->
            onRemove id model

        Trash id ->
            onTrash id model

        Fade id ->
            onFade id model

        Event _ ->
            Update.fromModel model


onRemove : Int -> Model -> UpdateResponse
onRemove id model =
    model
        |> remove id
        |> Update.fromModel


onTrash : Int -> Model -> UpdateResponse
onTrash id model =
    model
        |> get id
        |> Maybe.map
            (setState Garbage >> flip (replace id) model)
        |> Maybe.withDefault model
        |> Update.fromModel


onFade : Int -> Model -> UpdateResponse
onFade id model =
    model
        |> get id
        |> Maybe.map (\elem -> fade id elem model)
        |> Maybe.withDefault (Update.fromModel model)


fade : Int -> Toast -> Model -> UpdateResponse
fade id elem model =
    if elem.state == Garbage then
        onRemove id model
    else
        elem
            |> setState Fading
            |> flip (replace id) model
            |> waitDeath id


waitFade : Int -> Model -> UpdateResponse
waitFade id model =
    ( model
    , delay (3 * Time.second) (Fade id)
    , Dispatch.none
    )


waitDeath : Int -> Model -> UpdateResponse
waitDeath id model =
    ( model
    , delay (0.5 * Time.second) (Remove id)
    , Dispatch.none
    )


delay : Time -> msg -> Cmd msg
delay time msg =
    Process.sleep time
        |> Task.perform (\_ -> msg)
