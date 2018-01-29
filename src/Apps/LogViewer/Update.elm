module Apps.LogViewer.Update exposing (update)

import Dict
import Utils.React as React exposing (React)
import Game.Servers.Logs.Models as Logs
import Apps.LogViewer.Config exposing (..)
import Apps.LogViewer.Models exposing (..)
import Apps.LogViewer.Messages as LogViewer exposing (Msg(..))


type alias UpdateResponse msg =
    ( Model, React msg )


update :
    Config msg
    -> Msg
    -> Model
    -> UpdateResponse msg
update config msg model =
    case msg of
        ToogleExpand id ->
            model
                |> toggleExpand id
                |> flip (,) React.none

        UpdateTextFilter filter ->
            model
                |> updateTextFilter config filter
                |> flip (,) React.none

        EnterEditing id ->
            onEnterEditing config id model

        UpdateEditing id input ->
            model
                |> updateEditing id input
                |> flip (,) React.none

        LeaveEditing id ->
            model
                |> leaveEditing id
                |> flip (,) React.none

        ApplyEditing id ->
            onApplyEditing config id model

        StartEncryption id ->
            onStartEncryption config id model

        StartDecryption id ->
            onStartDecryption config id model

        StartHiding id ->
            onStartHiding config id model

        StartDeleting id ->
            onStartDeleting config id model


updateTextFilter : Config msg -> String -> Model -> Model
updateTextFilter config filter model =
    let
        filterer id log =
            case Logs.getContent log of
                Logs.NormalContent data ->
                    String.contains filter data.raw

                Logs.Encrypted ->
                    False

        filterCache =
            config.logs
                |> Logs.filter filterer
                |> Dict.keys
    in
        { model
            | filterText = filter
            , filterCache = filterCache
        }


onApplyEditing { onUpdateLog } id model =
    let
        model_ =
            leaveEditing id model

        react =
            case (getEdit id model) of
                Just edited ->
                    edited
                        |> onUpdateLog id
                        |> React.msg

                Nothing ->
                    React.none
    in
        ( model_, react )


onStartEncryption : Config msg -> Logs.ID -> Model -> UpdateResponse msg
onStartEncryption { onEncryptLog } id model =
    id
        |> onEncryptLog
        |> React.msg
        |> (,) model


onStartDecryption : Config msg -> Logs.ID -> Model -> UpdateResponse msg
onStartDecryption config id model =
    -- NOT IMPLEMENTED YET
    ( model, React.none )


onStartHiding : Config msg -> Logs.ID -> Model -> UpdateResponse msg
onStartHiding { onHideLog } id model =
    id
        |> onHideLog
        |> React.msg
        |> (,) model


onStartDeleting : Config msg -> Logs.ID -> Model -> UpdateResponse msg
onStartDeleting { onDeleteLog } id model =
    id
        |> onDeleteLog
        |> React.msg
        |> (,) model


onEnterEditing : Config msg -> Logs.ID -> Model -> UpdateResponse msg
onEnterEditing { logs } id model =
    let
        model_ =
            case Dict.get id logs.logs of
                Just log ->
                    case Logs.getContent log of
                        Logs.NormalContent data ->
                            updateEditing id data.raw model

                        Logs.Encrypted ->
                            model

                _ ->
                    model
    in
        ( model_, React.none )
