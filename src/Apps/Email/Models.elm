module Apps.Email.Models exposing (..)

import Apps.Email.Menu.Models as Menu


type alias Model =
    { menu : Menu.Model
    , activeContact : Maybe String
    }


name : String
name =
    "Thunderpigeon"


title : Model -> String
title model =
    "Thunderpigeon"


icon : String
icon =
    "email"


initialModel : Model
initialModel =
    { menu = Menu.initialMenu
    , activeContact = Nothing
    }


getActiveContact : Model -> Maybe String
getActiveContact =
    (.activeContact)


setActiveContact : Maybe String -> Model -> Model
setActiveContact v m =
    { m | activeContact = v }


windowInitSize : ( Float, Float )
windowInitSize =
    ( 200, 550 )
