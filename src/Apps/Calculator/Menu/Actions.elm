module Apps.Calculator.Menu.Actions exposing (actionHandler)

import Core.Dispatch as Dispatch exposing (Dispatch)
import Apps.Calculator.Models exposing (Model, Operator(..))
import Apps.Calculator.Messages as Calculator exposing (Msg)
import Apps.Calculator.Menu.Messages exposing (MenuAction(..))


actionHandler :
    Game.Data
    -> MenuAction
    -> Model
    -> ( Model, Cmd Calculator.Msg, Dispatch )
actionHandler data action ({ app } as model) =
    case action of
        Dummy ->
            ( model, Calculator.Msg, Dispatch )
