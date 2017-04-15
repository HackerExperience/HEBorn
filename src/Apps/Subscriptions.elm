module Apps.Subscriptions exposing (subscriptions)

import Core.Models exposing (CoreModel)
import OS.WindowManager.Models exposing (hasWindowOpen)
import OS.WindowManager.Windows exposing (GameWindow(..))
import Apps.Models exposing (AppModel)
import Apps.Messages exposing (AppMsg(..))
import Apps.Explorer.Subscriptions as Explorer


subscriptions : AppModel -> CoreModel -> Sub AppMsg
subscriptions model core =
    let
        explorer =
            subOnOpenWindow core
                ExplorerWindow
                MsgExplorer
                (Explorer.subscriptions model.explorer)
    in
        Sub.batch
            [ explorer
            ]


subOnOpenWindow :
    CoreModel
    -> GameWindow
    -> (a -> AppMsg)
    -> Sub a
    -> Sub AppMsg
subOnOpenWindow core window map sub =
    subOnTrue (hasWindowOpen core.os.wm window) map sub


subOnTrue : Bool -> (a -> AppMsg) -> Sub a -> Sub AppMsg
subOnTrue condition map sub =
    if condition then
        Sub.map map sub
    else
        Sub.none
