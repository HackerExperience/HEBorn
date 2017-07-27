module Apps.LocationPicker.Messages exposing (Msg(..))

import Apps.LocationPicker.Menu.Messages as Menu
import Json.Encode exposing (Value)


type Msg
    = MenuMsg Menu.Msg
    | MapClick Value
    | GeoResp Value
