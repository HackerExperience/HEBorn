module OS.Update exposing (update)

import Utils.React as React exposing (React)
import OS.Header.Messages as Header
import OS.Header.Update as Header
import OS.Config exposing (..)
import OS.Messages exposing (..)
import OS.Models exposing (..)
import OS.SessionManager.Messages as SessionManager
import OS.SessionManager.Update as SessionManager
import OS.Toasts.Messages as Toasts
import OS.Toasts.Update as Toasts


type alias UpdateResponse msg =
    ( Model, React msg )


update : Config msg -> Msg -> Model -> UpdateResponse msg
update config msg model =
    case msg of
        SessionManagerMsg msg ->
            onSessionManagerMsg config msg model

        HeaderMsg msg ->
            onHeaderMsg config msg model

        ToastsMsg msg ->
            onToastsMsg config msg model



-- internals


onSessionManagerMsg :
    Config msg
    -> SessionManager.Msg
    -> Model
    -> UpdateResponse msg
onSessionManagerMsg config msg model =
    let
        config_ =
            smConfig config

        ( sm, react ) =
            SessionManager.update config_ msg <| getSessionManager model

        model_ =
            setSessionManager sm model
    in
        ( model_, react )


onHeaderMsg :
    Config msg
    -> Header.Msg
    -> Model
    -> UpdateResponse msg
onHeaderMsg config msg model =
    let
        config_ =
            smConfig config

        ( header, react ) =
            Header.update
                (headerConfig config)
                msg
                (getHeader model)

        model_ =
            setHeader header model
    in
        -- CONFREFACT: Passthrough react
        ( model_, react )


onToastsMsg : Config msg -> Toasts.Msg -> Model -> UpdateResponse msg
onToastsMsg config msg model =
    let
        config_ =
            toastsConfig config

        ( toasts, react ) =
            Toasts.update config_ msg model.toasts

        model_ =
            { model | toasts = toasts }
    in
        ( model_, react )
