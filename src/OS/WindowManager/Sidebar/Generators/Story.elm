module OS.WindowManager.Sidebar.Generators.Story exposing (gen, hasQuests)

import Dict exposing (Dict)
import Game.Storyline.Models as Story
import Game.Storyline.Shared as Story
import OS.WindowManager.Sidebar.Shared exposing (WidgetId)
import Widgets.QuestHelper.Models as Quest


hasQuests : Maybe Story.Model -> Bool
hasQuests story =
    case story of
        Just story ->
            not <| Story.noQuests story

        Nothing ->
            False


gen : Story.Model -> Dict WidgetId Quest.Model
gen story =
    Dict.foldl contact Dict.empty story



-- internals


contact :
    Story.ContactId
    -> Story.Contact
    -> Dict WidgetId Quest.Model
    -> Dict WidgetId Quest.Model
contact id contact acu =
    case Story.getStep contact of
        Just step ->
            Dict.insert
                ("quest@" ++ id)
                (Quest.Model step <| Story.getNick contact)
                acu

        Nothing ->
            acu
