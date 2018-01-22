module OS.Toasts.Update exposing (update)

import Utils.React as React exposing (React)
import Process
import Task
import Time exposing (Time)
import OS.Toasts.Config exposing (..)
import OS.Toasts.Messages exposing (..)
import OS.Toasts.Models exposing (..)


type alias UpdateResponse msg =
    ( Model, React msg )


update :
    Config msg
    -> Msg
    -> Model
    -> UpdateResponse msg
update config msg model =
    case msg of
        Remove id ->
            onRemove config id model

        Trash id ->
            onTrash config id model

        Fade id ->
            onFade config id model

        HandleAccount content ->
            model
                |> insert (Toast (Account content) Alive)
                |> uncurry (waitFade config)

        HandleServers cid content ->
            model
                |> insert (Toast (Server cid content) Alive)
                |> uncurry (waitFade config)


onRemove : Config msg -> Int -> Model -> UpdateResponse msg
onRemove config id model =
    let
        model_ =
            remove id model
    in
        ( model_, React.none )


onTrash : Config msg -> Int -> Model -> UpdateResponse msg
onTrash config id model =
    let
        setState_ =
            setState Garbage >> flip (replace id) model

        model_ =
            Maybe.map setState_ (get id model)
                |> Maybe.withDefault model
    in
        ( model_, React.none )


onFade : Config msg -> Int -> Model -> UpdateResponse msg
onFade config id model =
    let
        fade_ elem =
            fade config id elem model
    in
        Maybe.map fade_ (get id model)
            |> Maybe.withDefault ( model, React.none )


fade : Config msg -> Int -> Toast -> Model -> UpdateResponse msg
fade config id elem model =
    let
        setState_ =
            setState Garbage >> flip (replace id) model
    in
        if elem.state == Garbage then
            onRemove config id model
        else
            setState_ elem
                |> waitDeath config id


waitFade : Config msg -> Int -> Model -> UpdateResponse msg
waitFade config id model =
    ( model
    , React.map config.toMsg <| React.cmd <| delay (3 * Time.second) (Fade id)
    )


waitDeath : Config msg -> Int -> Model -> UpdateResponse msg
waitDeath config id model =
    ( model
    , React.map config.toMsg <| React.cmd <| delay (0.5 * Time.second) (Remove id)
    )


delay : Time -> msg -> Cmd msg
delay time msg =
    Task.perform (\_ -> msg) <| Process.sleep time
