module Landing.Subscriptions exposing (subscriptions)

import Landing.Models exposing (..)
import Landing.Messages exposing (..)
import Utils.Ports.OnLoad exposing (windowLoaded)


subscriptions : Model -> Sub Msg
subscriptions model =
    windowLoaded LoadingEnd
