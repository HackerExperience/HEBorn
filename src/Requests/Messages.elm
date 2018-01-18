module Requests.Messages exposing (Msg(..))

import Requests.Types exposing (..)


type Msg msg
    = RequestHttpMsg Topic Context String msg
    | RequestWebsocketMsg Topic Context String msg
