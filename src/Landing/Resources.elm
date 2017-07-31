module Landing.Resources exposing (..)


type Class
    = Title
    | Label
    | Input
    | Button
    | Loaded


prefix : String
prefix =
    "land"


viewId : String
viewId =
    prefix ++ "View"


introId : String
introId =
    prefix ++ "Intro"


displayManagerId : String
displayManagerId =
    prefix ++ "DM"
