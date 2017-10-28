module Core.Dispatch.Websocket exposing (..)

import Driver.Websocket.Channels exposing (Channel)
import Json.Encode exposing (Value)
import Events.Account.PasswordAcquired as PasswordAcquired
import Events.Account.Story.StepProceeded as StoryStepProceeded
import Events.Account.Story.NewEmail as StoryNewEmail
import Events.Account.Story.ReplyUnlocked as StoryReplyUnlocked
import Events.Server.Filesystem.NewFile as NewFile
import Events.Server.Logs.Changed as LogsChanged
import Events.Server.Processes.Started as ProcessStarted
import Events.Server.Processes.Conclusion as ProcessConclusion
import Events.Server.Processes.BruteforceFailed as BruteforceFailed
import Events.Server.Processes.Changed as ProcessesChanged


{-| Messages related to the websocket driver.
-}
type Dispatch
    = Connected String
    | Disconnected
    | Join Channel (Maybe Value)
    | Joined Channel Value
    | JoinFailed Channel Value
    | Leave Channel
    | Leaved Channel (Maybe Value)
    | Event Channel Event


type Event
    = AccountEvent AccountEvent
    | ServerEvent ServerEvent


type AccountEvent
    = PasswordAcquired PasswordAcquired.Data
    | StoryStepProceeded StoryStepProceeded.Data
    | StoryNewEmail StoryNewEmail.Data
    | StoryReplyUnlocked StoryReplyUnlocked.Data


type ServerEvent
    = LogsChanged LogsChanged.Data
    | NewFile NewFile.Data
    | ProcessStarted ProcessStarted.Data
    | ProcessConclusion ProcessConclusion.Data
    | BruteforceFailed BruteforceFailed.Data
    | ProcessesChanged ProcessesChanged.Data
