module Apps.ServersGears.Messages exposing (Msg(..))

import Apps.ServersGears.Models exposing (..)


type Msg
    = Select (Maybe Selection)
    | Unlink
    | Save
