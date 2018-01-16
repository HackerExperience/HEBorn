module Apps.FloatingHeads.Models exposing (..)

import Game.Storyline.Emails.Models as Emails exposing (ID)
import Apps.FloatingHeads.Menu.Models as Menu
import Apps.Reference exposing (Reference)


type alias Model =
    { me : Reference
    , menu : Menu.Model
    , activeContact : ID
    , mode : Mode
    }


type Mode
    = Compact
    | Expanded


name : String
name =
    "floatingheads"


title : Model -> String
title model =
    "FloatingHeads Title"


icon : String
icon =
    "floatingheads"


initialModel : Reference -> Model
initialModel me =
    { me = me
    , menu = Menu.initialMenu
    , activeContact = "friend"
    , mode = Expanded
    }


getActiveContact : Model -> String
getActiveContact =
    (.activeContact)


setActiveContact : String -> Model -> Model
setActiveContact v m =
    { m | activeContact = v }
