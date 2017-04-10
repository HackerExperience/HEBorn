module OS.WindowManager.ContextHandler.Update exposing (update)

import Utils
import Core.Messages exposing (CoreMsg)
import OS.Messages exposing (OSMsg(..))
import OS.WindowManager.ContextHandler.Messages exposing (ContextMsg(..))
import OS.WindowManager.ContextHandler.Models exposing (Model)
import OS.WindowManager.Windows exposing (GameWindow(..))
import Apps.Messages


update : ContextMsg -> Model -> ( Model, Cmd OSMsg, List CoreMsg )
update msg model =
    case msg of
        ExplorerContext subMsg ->
            let
                cmd =
                    Utils.msgToCmd (ToApp Apps.Messages.NoOp)
            in
                ( model, cmd, [] )

        _ ->
            ( model, Cmd.none, [] )
