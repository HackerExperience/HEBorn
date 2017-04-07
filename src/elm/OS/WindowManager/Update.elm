module OS.WindowManager.Update exposing (..)


import Random.Pcg exposing (Seed)
import OS.WindowManager.Models exposing ( Model
                                        , openWindow, closeWindow)
import OS.WindowManager.Messages exposing (Msg(..))


update : Msg -> Model -> Seed -> ( Model, Cmd Msg)
update msg model seed =
    case msg of

        OpenWindow window ->
            let
                (windows_, seed_) = openWindow model window
                model_ = {model | windows = windows_, seed = seed_}
            in
                (model_, Cmd.none)

        CloseWindow id ->
            let
                windows_ = closeWindow model id
            in
                ({model | windows = windows_}, Cmd.none)

        Event _ ->
            (model, Cmd.none)

        Request _ ->
            (model, Cmd.none)

        Response _ _ ->
            (model, Cmd.none)
