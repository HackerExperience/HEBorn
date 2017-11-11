module Decoders.Client exposing (setupPages)

import Json.Decode as Decode exposing (Decoder, field, succeed, oneOf)
import Setup.Types as Setup
import Setup.Models as Setup
import Decoders.Setup


setupPages : Decoder Setup.Pages
setupPages =
    -- TODO: remove this fallback after getting helix support
    oneOf
        [ succeed Setup.pageOrder
        , Decoders.Setup.remainingPages
            |> field "pages"
            |> field "setup"
            |> field "client"
        ]
