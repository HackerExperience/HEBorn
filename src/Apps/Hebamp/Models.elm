module Apps.Hebamp.Models exposing (..)

import Apps.Hebamp.Menu.Models as Menu


type alias Hebamp =
    { audioData : AudioData }


type alias Model =
    { app : Hebamp
    , menu : Menu.Model
    }


name : String
name =
    "Hebamp"


title : Model -> String
title model =
    ""


icon : String
icon =
    "hebamp"


initialModel : Model
initialModel =
    { app = initialHebamp
    , menu = Menu.initialMenu
    }


initialHebamp : Hebamp
initialHebamp =
    { audioData = initialAudioData
    }


type alias AudioData =
    { mediaUrl : String
    , mediaType : String
    , label : String
    , currentTime : Float
    , duration : Float
    }


initialAudioData : AudioData
initialAudioData =
    { mediaUrl = "http://srv95.listentoyoutube.com/download/4pWYcGlom2dtZrWr2NmcbbVhnGttZnBtnZyYtIWZ26aZoY2nv9LYrK6SzQ==/Madonna%20-%20Hung%20Up%20%28Official%20Music%20Video%29.mp3"
    , mediaType = "audio/mp3"
    , label = "MADONNA - HUNG UP"
    , currentTime = 0.0
    , duration = 332
    }
