module OS.WindowManager.Windows exposing (GameWindow(..), WindowContext(..))


type GameWindow
    = ExplorerWindow
    | LogViewerWindow
    | BrowserWindow


type WindowContext
    = ContextGateway
    | ContextEndpoint
