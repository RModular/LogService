local FireLog= {}
local Types = require(game.ServerScriptService.Types)

FireLog.OnLogFired = script.Parent.Parent.Events:WaitForChild('OnLogFired')

FireLog.LogHistory = {}
FireLog.MaxLogEntries = 100
FireLog.AllowedLevels = { "Info", "Warning", "Error" }

function FireLog:FireLog(message: string, level: Types.LogType)
	assert(type(message) == "string", "FireLog: message must be a string")
	assert(table.find(FireLog.AllowedLevels, level), "FireLog: Invalid log level")

	-- Create log entry
	local logEntry: Types.LogEntry = {
		Message = message,
		Level = level,
		Timestamp = os.time()
	}

	-- Store log entry
	table.insert(FireLog.LogHistory, logEntry)

	if #FireLog.LogHistory > FireLog.MaxLogEntries then
		table.remove(FireLog.LogHistory, 1) -- Remove oldest log
	end

	FireLog.OnLogFired:Fire(logEntry)
end

return FireLog
