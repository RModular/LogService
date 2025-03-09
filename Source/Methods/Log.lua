local Module = {}

local Types = require(script.Parent.Parent:WaitForChild('Types'))
local Config = require(script.Parent.Parent:WaitForChild('Configuration'))
local LogHistory = require(script.Parent.Parent:WaitForChild('History'))

-- Events
local OnLogFiredEvent: BindableEvent = script.Parent.Parent.Events:WaitForChild('OnLogFired') :: BindableEvent
local OnLogInfoEvent: BindableEvent = script.Parent.Parent.Events:WaitForChild('OnLogInfo') :: BindableEvent
local OnLogWarnEvent: BindableEvent = script.Parent.Parent.Events:WaitForChild('OnLogWarn') :: BindableEvent
local OnLogErrorEvent: BindableEvent = script.Parent.Parent.Events:WaitForChild('OnLogError') :: BindableEvent

-- Logs a message with a specified log level and optional details.
function Module:Log(message: string, logLevel: Types.LogType?, outputDetails: boolean?): nil
    -- Default values
    local Message: string = message
    local Level: Types.LogType = logLevel or "Info"
    local Details: boolean = outputDetails or false
    
    -- Checking argument types
    assert(typeof(Message) == "string", 'LOG: "message" argument must be a string.')
    assert(table.find(Config.AllowedLevels, Level), 'LOG: "logLevel" argument must be one of "Info", "Warning", or "Error".')
    assert(typeof(Details) == "boolean", 'LOG: "outputDetails" argument must be a boolean.')

    -- Create LogEntry table with correct type structure
    local LogEntry: Types.LogEntry = {
        Message = Message,
        Level = Level,
        Timestamp = os.time(),
    }

    -- Store log entry, maintaining max history limit
    table.insert(LogHistory.LogHistory, LogEntry)
    if #LogHistory.LogHistory > LogHistory.MaxLogEntries then
        table.remove(LogHistory.LogHistory, 1) -- Remove oldest log
    end

    -- Handle logging and event firing
    if Level == "Info" then
        if Details then
            print(string.format("🔵 [INFO] (%d) - %s", os.time(), Message))
        else
            print(string.format("🔵 [INFO] - %s", Message))
        end
        OnLogFiredEvent:Fire(LogEntry)
        OnLogInfoEvent:Fire(LogEntry)
    
    elseif Level == "Warning" then
        if Details then
            print(string.format("🟠 [WARN] (%d) - %s", os.time(), Message))
        else
            print(string.format("🟠 [WARN] - %s", Message))
        end
        OnLogFiredEvent:Fire(LogEntry)
        OnLogWarnEvent:Fire(LogEntry)
    
    elseif Level == "Error" then
        if Details then
            print(string.format("🔴 [ERROR] (%d) - %s", os.time(), Message))
        else
            print(string.format("🔴 [ERROR] - %s", Message))
        end
        OnLogFiredEvent:Fire(LogEntry)
        OnLogErrorEvent:Fire(LogEntry)
    end
end

return Module
