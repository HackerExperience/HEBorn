module Apps.Instances.Dispatcher exposing (instanceDispatcher)

import Core.Dispatcher exposing (callExplorer)
import Core.Messages exposing (CoreMsg)
import OS.WindowManager.Windows exposing (GameWindow(..))


-- instanceDispatcher : GameWindow -> msg -> CoreMsg


instanceDispatcher window msg =
    case window of
        ExplorerWindow ->
            callExplorer msg
