module OS.WindowManager.Messages exposing (..)


import Events.Models
import Requests.Models
import OS.WindowManager.Windows exposing (GameWindow)
import OS.WindowManager.Models exposing (WindowID)


type Msg
    = OpenWindow GameWindow
    | CloseWindow WindowID
    | Event Events.Models.Event
    | Request Requests.Models.Request
    | Response Requests.Models.Request Requests.Models.Response
