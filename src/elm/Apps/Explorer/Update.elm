module Apps.Explorer.Update exposing (update)

import Core.Messages exposing (CoreMsg)
import Game.Models exposing (GameModel)
import Apps.Explorer.Models exposing (Model)
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

        ContextMsg (MsgContext.MenuClick action) ->
            actionHandler action model game

        ContextMsg subMsg ->
            let
                ( context_, cmd, coreMsg ) =
                    Apps.Explorer.Context.Update.update subMsg model.context game

                cmd_ =
                    Cmd.map ContextMsg cmd
            in
                ( { model | context = context_ }, cmd_, coreMsg )
