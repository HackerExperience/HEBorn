module Apps.Explorer.Update exposing (update)

import Core.Messages exposing (CoreMsg)
import Game.Models exposing (GameModel)
import Apps.Instances.Models as Instance
import Apps.Explorer.Models exposing (Model, initialExplorer)
import Apps.Explorer.Messages exposing (Msg(..))
import Apps.Explorer.Context.Messages as MsgContext
import Apps.Explorer.Context.Update
import Apps.Explorer.Context.Actions exposing (actionHandler)


update : Msg -> Model -> GameModel -> ( Model, Cmd Msg, List CoreMsg )
update msg model game =
    case msg of
        Event event ->
            ( model, Cmd.none, [] )

        Request _ ->
            ( model, Cmd.none, [] )

        Response request data ->
            ( model, Cmd.none, [] )

        OpenInstance id ->
            let
                instances_ =
                    Instance.open model.instances id initialExplorer
            in
                ( { model | instances = instances_ }, Cmd.none, [] )

        CloseInstance id ->
            let
                instances_ =
                    Instance.close model.instances id
            in
                ( { model | instances = instances_ }, Cmd.none, [] )

        ContextMsg (MsgContext.MenuClick action id) ->
            actionHandler action id model game

        ContextMsg subMsg ->
            let
                ( context_, cmd, coreMsg ) =
                    Apps.Explorer.Context.Update.update subMsg model.context game

                cmd_ =
                    Cmd.map ContextMsg cmd
            in
                ( { model | context = context_ }, cmd_, coreMsg )
