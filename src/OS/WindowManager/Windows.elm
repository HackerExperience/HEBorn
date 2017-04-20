module OS.WindowManager.Windows exposing (GameWindow(..), WindowContext(..))


type GameWindow
    = ExplorerWindow
    | LogViewerWindow


type WindowContext
    = ContextGateway
    | ContextEndpoint
