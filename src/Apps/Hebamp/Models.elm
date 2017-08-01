module Apps.Hebamp.Models exposing (..)

import Apps.Hebamp.Menu.Models as Menu


type alias Hebamp =
    { playerId : String
    , now : Maybe AudioData
    , prev : List AudioData
    , next : List AudioData
    , currentTime : Float
    }


type alias Model =
    { app : Hebamp
    , menu : Menu.Model
    }


name : String
name =
    "Hebamp"


title : Model -> String
title model =
    let
        musicTitle =
            model.app.now
                |> Maybe.map .label
                |> Maybe.withDefault ""

        posfix =
            if (String.length musicTitle) > 12 then
                Just (": \"" ++ (String.left 10 musicTitle) ++ "[...]\"")
            else if (String.length musicTitle) > 0 then
                Just (": \"" ++ musicTitle ++ "\"")
            else
                Nothing
    in
        posfix
            |> Maybe.map ((++) name)
            |> Maybe.withDefault name


icon : String
icon =
    "hebamp"


initialModel : String -> Model
initialModel id =
    { app = initialHebamp id
    , menu = Menu.initialMenu
    }


initialHebamp : String -> Hebamp
initialHebamp id =
    { playerId = "audio-" ++ id
    , now =
        Just
            { mediaUrl = "//upload.wikimedia.org/wikipedia/en/2/2a/Nyan_cat.ogg"
            , mediaType = "audio/ogg"
            , label = "Nyan Cat"
            , duration = 7.4
            }
    , prev = []
    , next = []
    , currentTime = 0
    }


type alias AudioData =
    { mediaUrl : String
    , mediaType : String
    , label : String
    , duration : Float
    }
