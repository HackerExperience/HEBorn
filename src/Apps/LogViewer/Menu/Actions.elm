module Apps.LogViewer.Menu.Actions exposing (actionHandler)

import Dict
import Core.Messages exposing (CoreMsg)
import Game.Models exposing (GameModel)
import Game.Servers.Models exposing (localhostServerID)
import Apps.Instances.Models as Instance exposing (InstanceID)
import Apps.Context as Context
import Apps.LogViewer.Models
    exposing
        ( Model
        , initialLogViewer
        , getLogViewerInstance
        , LogEventStatus(..)
        , entryEnterEditing
        , entryApplyEditing
        , entryLeaveEditing
        , entryUpdateEditing
        )
import Apps.LogViewer.Messages exposing (Msg)
import Apps.LogViewer.Menu.Messages exposing (MenuAction(..))


actionHandler :
    MenuAction
    -> InstanceID
    -> Model
    -> GameModel
    -> ( Model, Cmd Msg, List CoreMsg )
actionHandler action instanceID model game =
    case action of
        NormalEntryEdit logID ->
            let
                instance =
                    getLogViewerInstance model.instances instanceID

                context =
                    instance |> Context.state |> Maybe.withDefault (initialLogViewer localhostServerID)

                entries_ =
                    entryEnterEditing logID context.entries

                context_ =
                    { context | entries = entries_ }

                instance_ =
                    Context.update instance (Just context_)

                instances_ =
                    Instance.update model.instances instanceID instance_
            in
                ( { model | instances = instances_ }, Cmd.none, [] )

        EdittingEntryApply logID ->
            let
                instance =
                    getLogViewerInstance model.instances instanceID

                context =
                    instance |> Context.state |> Maybe.withDefault (initialLogViewer localhostServerID)

                entries_ =
                    entryApplyEditing logID context.entries

                context_ =
                    { context | entries = entries_ }

                instance_ =
                    Context.update instance (Just context_)

                instances_ =
                    Instance.update model.instances instanceID instance_
            in
                ( { model | instances = instances_ }, Cmd.none, [] )

        EdittingEntryCancel logID ->
            let
                instance =
                    getLogViewerInstance model.instances instanceID

                context =
                    instance |> Context.state |> Maybe.withDefault (initialLogViewer localhostServerID)

                entries_ =
                    entryLeaveEditing logID context.entries

                context_ =
                    { context | entries = entries_ }

                instance_ =
                    Context.update instance (Just context_)

                instances_ =
                    Instance.update model.instances instanceID instance_
            in
                ( { model | instances = instances_ }, Cmd.none, [] )
