module Apps.Explorer.Update exposing (update)

import ContextMenu exposing (ContextMenu)
import Core.Messages exposing (CoreMsg)
import Game.Models exposing (GameModel)
import Apps.Explorer.Models exposing (Model)
import Apps.Explorer.Messages exposing (Msg(..))


update : Msg -> Model -> GameModel -> ( Model, Cmd Msg, List CoreMsg )
update msg model game =
    case msg of
        Event event ->
            ( model, Cmd.none, [] )

        Request _ ->
            ( model, Cmd.none, [] )

        Response request data ->
            ( model, Cmd.none, [] )

        ContextMenuMsg msg ->
            let
                ( contextMenu, cmd ) =
                    ContextMenu.update msg model.context.menu

                context =
                    model.context

                context_ =
                    { context | menu = contextMenu }
            in
                ( { model | context = context_ }, Cmd.map ContextMenuMsg cmd, [] )

        Item int ->
            ( model, Cmd.none, [] )
