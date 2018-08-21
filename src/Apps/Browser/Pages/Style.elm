module Apps.Browser.Pages.Style exposing (cssList)

import Css exposing (Stylesheet)
import Apps.Browser.Pages.Bank.Style as Bank

cssList : List Stylesheet
cssList =
    [ Bank.css
    ]
