module Apps.Popup.Models exposing (..)

import Html exposing (Html, text)
import Apps.Popup.Menu.Models as Menu
import Apps.Popup.Data exposing (Data)
import Apps.Reference exposing (Reference)
import Apps.Popup.Shared exposing (PopupType(..))


type alias Model =
    { me : Reference
    , menu : Menu.Model
    , title : String
    , content : Html Never
    , type_ : PopupType
    }


name : String
name =
    "Popup App"


title : Model -> String
title model =
    model.title


icon : String
icon =
    "popup"


initialModel : PopupType -> Reference -> Model
initialModel type_ me =
    case type_ of
        ActivationPopup ->
            { me = me
            , menu = Menu.initialMenu
            , title = "Activation"
            , content = text "Isso aqui é uma ativação"
            , type_ = type_
            }

        VirusPopup ->
            { me = me
            , menu = Menu.initialMenu
            , title = "Virus"
            , content = text "Varias coisa"
            , type_ = type_
            }


windowInitSize : ( Float, Float )
windowInitSize =
    --TODO: Implement size depending on PopupType
    ( 400, 600 )
