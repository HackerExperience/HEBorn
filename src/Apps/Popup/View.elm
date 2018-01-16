module Apps.Popup.View exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.CssHelpers
import Game.Data as Game
import Apps.Popup.Messages exposing (Msg(..))
import Apps.Popup.Models exposing (..)
import Apps.Popup.Resources exposing (Classes(..), prefix)
import Apps.Popup.Shared exposing (PopupType(..))
import Apps.Popup.Menu.View exposing (..)


{ id, class, classList } =
    Html.CssHelpers.withNamespace prefix



-- Popup Template:
-- otherPopup : Game.Data -> Model -> Html msg
-- otherPopup data model =
--     div
--         []
--         [ button [ onClick MsgOk ] [ text "OK" ]
--         , button [ onClick MsgCancel ] [ text "Cancel" ]
--         ]


view : Game.Data -> Model -> Html Msg
view data model =
    div
        [ menuForDummy ]
        [ renderPopup model
        , buttonsByType data model
        , menuView model
        ]


renderPopup : Model -> Html Msg
renderPopup model =
    div
        [ class [ PopupMessage ] ]
        [ Html.map never model.content ]


buttonsByType : Game.Data -> Model -> Html Msg
buttonsByType data model =
    case model.type_ of
        ActivationPopup ->
            activationPopup data model

        VirusPopup ->
            virusPopup data model


activationPopup : Game.Data -> Model -> Html Msg
activationPopup data model =
    div
        [ class [ PopupInteraction ] ]
        [ button [ onClick Activation ] [ text "OK" ]
        , button [ onClick ContinueOnCampaign ] [ text "Continue on Campaign" ]
        ]


virusPopup : Game.Data -> Model -> Html Msg
virusPopup data model =
    div
        [ class [ PopupInteraction ] ]
        [ text "" ]
