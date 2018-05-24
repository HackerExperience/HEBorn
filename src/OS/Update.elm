module OS.Update exposing (update)

import Utils.React as React exposing (React)
import Core.Flags as Flags
import OS.Header.Messages as Header
import OS.Header.Update as Header
import OS.Map.Messages as Map
import OS.Map.Update as Map
import OS.WindowManager.Messages as WindowManager
import OS.WindowManager.Update as WindowManager
import OS.Toasts.Messages as Toasts
import OS.Toasts.Update as Toasts
import OS.Config exposing (..)
import OS.Messages exposing (..)
import OS.Models exposing (..)


type alias UpdateResponse msg =
    ( Model, React msg )


update : Config msg -> Msg -> Model -> UpdateResponse msg
update config msg model =
    case msg of
        HeaderMsg msg ->
            onHeaderMsg config msg model

        MapMsg msg ->
            if Flags.isHE2 config.flags then
                onMapMsg config msg model
            else
                ( model, React.none )

        WindowManagerMsg msg ->
            onWindowManagerMsg config msg model

        ToastsMsg msg ->
            onToastsMsg config msg model



-- internals


onHeaderMsg :
    Config msg
    -> Header.Msg
    -> Model
    -> UpdateResponse msg
onHeaderMsg config msg model =
    model
        |> getHeader
        |> Header.update (headerConfig config) msg
        |> Tuple.mapFirst (flip setHeader model)


onMapMsg :
    Config msg
    -> Map.Msg
    -> Model
    -> UpdateResponse msg
onMapMsg config msg model =
    model
        |> getMap
        |> Map.update (mapConfig config) msg
        |> Tuple.mapFirst (flip setMap model)


onWindowManagerMsg :
    Config msg
    -> WindowManager.Msg
    -> Model
    -> UpdateResponse msg
onWindowManagerMsg config msg model =
    model
        |> getWindowManager
        |> WindowManager.update (windowManagerConfig config) msg
        |> Tuple.mapFirst (flip setWindowManager model)


onToastsMsg : Config msg -> Toasts.Msg -> Model -> UpdateResponse msg
onToastsMsg config msg model =
    model
        |> getToasts
        |> Toasts.update (toastsConfig config) msg
        |> Tuple.mapFirst (flip setToasts model)
