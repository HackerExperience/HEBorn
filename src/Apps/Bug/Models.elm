module Apps.Bug.Models exposing (..)


type alias Model =
    {}


name : String
name =
    "The bug"


title : Model -> String
title model =
    "Bugtura"


icon : String
icon =
    "bug"


initialModel : Model
initialModel =
    {}
