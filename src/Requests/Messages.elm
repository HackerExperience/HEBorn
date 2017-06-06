module Requests.Messages exposing (Msg(..))

import Requests.Types exposing (..)


type alias Path =
    String


type alias Payload =
    String


type alias Channel =
    String


type Msg msg
    = RequestHttpMsg Topic Context String msg
    | RequestWebsocketMsg Topic Context String msg
