local LogService = {}

local Types = require(script.Parent.Parent:WaitForChild("Types"))
local Config = require(script.Parent.Parent:WaitForChild("Configuration"))
local LogHistory = require(script.Parent.Parent:WaitForChild("History"))
local SendToDiscord = require(script.Parent.Parent.Methods:WaitForChild("SendLogToDiscord"))

-- Events
local OnLogFiredEvent: BindableEvent = script.Parent.Parent.Events:WaitForChild("OnLogFired") :: BindableEvent
local OnLogInfoEvent: BindableEvent = script.Parent.Parent.Events:WaitForChild("OnLogInfo") :: BindableEvent
local OnLogWarnEvent: BindableEvent = script.Parent.Parent.Events:WaitForChild("OnLogWarn") :: BindableEvent
local OnLogErrorEvent: BindableEvent = script.Parent.Parent.Events:WaitForChild("OnLogError") :: BindableEvent
local OnLogDebugEvent: BindableEvent = script.Parent.Parent.Events:WaitForChild("OnLogDebug") :: BindableEvent
local OnLogCriticalEvent: BindableEvent = script.Parent.Parent.Events:WaitForChild("OnLogCritical") :: BindableEvent

-- Log symbols
local logSymbols = {
	Debug = "🟣",
	Info = "🔵",
	Warning = "🟠",
	Error = "🔴",
	Critical = "⚫"
}

-- Logs a message with a specified log level and optional details and Discord webhook.
function LogService:Log(message: string, logLevel: Types.LogType?, outputDetails: boolean?, sendToDiscord: boolean?)
	-- Default values
	local Level: Types.LogType = logLevel or "Info"
	local Details: boolean = outputDetails == true
	local _SendToDiscord: boolean = sendToDiscord == true

	-- Validate arguments
	assert(typeof(message) == "string", 'LOG: "message" argument must be a string.')
	assert(table.find(Config.AllowedLevels, Level), 
		`LOG: "logLevel" must be one of: ${table.concat(Config.AllowedLevels, ", ")}`)

	-- Create log entry
	local LogEntry: Types.LogEntry = {
		Message = message,
		Level = Level,
		Timestamp = os.time(),
		Caller = debug.traceback(nil, 2)
	}

	-- Store log entry in a circular buffer
	local history = LogHistory.LogHistory
	history[(#history % LogHistory.MaxLogEntries) + 1] = LogEntry

	-- Print log
	local symbol = logSymbols[Level] or "ℹ️"
	if Details then
		print(string.format("%s [%s] (%d) - %s", symbol, Level:upper(), os.time(), message))
	else
		print(string.format("%s [%s] - %s", symbol, Level:upper(), message))
	end

	-- Fire corresponding events
	OnLogFiredEvent:Fire(LogEntry)
	if Level == "Info" then
		OnLogInfoEvent:Fire(LogEntry)
	elseif Level == "Warning" then
		OnLogWarnEvent:Fire(LogEntry)
	elseif Level == "Error" then
		OnLogErrorEvent:Fire(LogEntry)
	elseif Level == "Debug" then
		OnLogDebugEvent:Fire(LogEntry)
	elseif Level == "Critical" then
		OnLogCriticalEvent:Fire(LogEntry)
	end

	-- Send log to Discord
	if _SendToDiscord then
		SendToDiscord:SendLogToDiscord(LogEntry)
	end

	return LogEntry
end

return LogService
