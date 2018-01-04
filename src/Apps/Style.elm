module Apps.Style exposing (cssList)

import Css exposing (Stylesheet)
import Apps.Explorer.Style as Explorer
import Apps.LogViewer.Style as LogViewer
import Apps.Browser.Style as Browser
import Apps.TaskManager.Style as TaskManager
import Apps.DBAdmin.Style as DBAdmin
import Apps.ConnManager.Style as ConnManager
import Apps.Finance.Style as Finance
import Apps.BounceManager.Style as BounceManager
import Apps.Hebamp.Style as Hebamp
import Apps.LocationPicker.Style as LocationPicker
import Apps.LanViewer.Style as LanViewer
import Apps.Email.Style as Email
import Apps.Bug.Style as Bug
import Apps.Calculator.Style as Calculator
import Apps.LogFlix.Style as LogFlix
import Apps.ServersGears.Style as ServersGears


cssList : List Stylesheet
cssList =
    [ Explorer.css
    , LogViewer.css
    , Browser.css
    , TaskManager.css
    , DBAdmin.css
    , ConnManager.css
    , Finance.css
    , BounceManager.css
    , Hebamp.css
    , LocationPicker.css
    , LanViewer.css
    , Email.css
    , Bug.css
    , Calculator.css
    , ServersGears.css
    , LogFlix.css
    ]
