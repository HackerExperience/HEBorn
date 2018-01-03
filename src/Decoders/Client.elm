module Decoders.Client exposing (setupPages)

import Json.Decode as Decode exposing (Decoder, field, succeed, oneOf)
import Setup.Types as Setup
import Decoders.Setup


setupPages : Decoder Setup.Pages
setupPages =
    Decoders.Setup.remainingPages
        |> field "pages"
        |> field "setup"
        |> field "client"
