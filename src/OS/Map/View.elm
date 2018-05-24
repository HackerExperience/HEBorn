module OS.Map.View exposing (view)

import Html exposing (Html, div)
import Native.Untouchable
import OS.Map.Config exposing (..)
import OS.Map.Models exposing (..)


view : Config msg -> Model -> Html msg
view config model =
    Native.Untouchable.node "hemapWallpaper" mapId
