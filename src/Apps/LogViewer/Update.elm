module Apps.LogViewer.Update exposing (update)

import Dict
import Core.Messages exposing (CoreMsg)
import Game.Models exposing (GameModel)
import Apps.Instances.Models as Instance
import Apps.Context as Context
import Apps.LogViewer.Models
    exposing
        ( Model
        , initialLogViewer
        , initialLogViewerContext
        , loadLogViewerContext
        , getLogViewerInstance
        )
import Apps.LogViewer.Messages exposing (Msg(..))
import Apps.LogViewer.Context.Messages as MsgContext
import Apps.LogViewer.Context.Update
import Apps.LogViewer.Context.Actions exposing (actionHandler)


update : Msg -> Model -> GameModel -> ( Model, Cmd Msg, List CoreMsg )
update msg model game =
    case msg of
        -- LogViewer
        -- Instance
        OpenInstance id ->
            let
                instances_ =
                    Instance.open
                        model.instances
                        id
                        (loadLogViewerContext "" game)
            in
                ( { model | instances = instances_ }, Cmd.none, [] )

        CloseInstance id ->
            let
                instances_ =
                    Instance.close model.instances id
            in
                ( { model | instances = instances_ }, Cmd.none, [] )

        -- Context
        SwitchContext id ->
            let
                instance =
                    getLogViewerInstance model.instances id

                instance_ =
                    Context.switch instance

                instances_ =
                    Instance.update model.instances id instance_
            in
                ( { model | instances = instances_ }, Cmd.none, [] )

        -- Menu
        ContextMsg (MsgContext.MenuClick action id) ->
            actionHandler action id model game

        ContextMsg subMsg ->
            let
                ( menu_, cmd, coreMsg ) =
                    Apps.LogViewer.Context.Update.update subMsg model.menu game

                cmd_ =
                    Cmd.map ContextMsg cmd
            in
                ( { model | menu = menu_ }, cmd_, coreMsg )

        -- Server-side notifications
        Event event ->
            ( model, Cmd.none, [] )

        Request _ ->
            ( model, Cmd.none, [] )

        Response request data ->
            ( model, Cmd.none, [] )

        -- Real acts
        ToogleLog instanceID logID ->
            let
                instance =
                    getLogViewerInstance model.instances instanceID

                context =
                    instance |> Context.state |> Maybe.withDefault initialLogViewer

                entries =
                    context.entries

                entries_ =
                    Dict.update logID
                        (Maybe.andThen
                            (\x -> Just { x | expanded = not x.expanded })
                        )
                        entries

                context_ =
                    { context | entries = entries_ }

                instance_ =
                    Context.update instance (Just context_)

                instances_ =
                    Instance.update model.instances instanceID instance_
            in
                ( { model | instances = instances_ }, Cmd.none, [] )
