module Apps.LogViewer.View exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.CssHelpers
import Css exposing (asPairs)
import Game.Models exposing (GameModel)
import Game.Servers.Filesystem.Models exposing (FilePath)
import Apps.Instances.Models as Instance exposing (InstanceID)
import Apps.Context as Context
import Apps.LogViewer.Messages exposing (Msg(..))
import Apps.LogViewer.Models exposing (Model, LogViewer, getState)
import Apps.LogViewer.Context.Models exposing (Context(..))
import Apps.LogViewer.Style exposing (Classes(..))


{ id, class, classList } =
    Html.CssHelpers.withNamespace "logvw"


styles : List Css.Mixin -> Attribute Msg
styles =
    Css.asPairs >> style


view : Model -> InstanceID -> GameModel -> Html Msg
view model id game =
    let
        logvw =
            getState model id
    in
        div []
            []
