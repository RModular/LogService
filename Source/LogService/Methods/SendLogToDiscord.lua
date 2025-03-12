local Module = {}

local HttpService = game:GetService("HttpService")
local Config = require(script.Parent.Parent:WaitForChild('Configuration')) -- Config module

--- Sends a log entry to a configured Discord webhook.
function Module:SendLogToDiscord(logEntry: Types.LogEntry): boolean
	if Config.WebhookURL == "" or not Config.WebhookURL then return false, "Webhook URL is not configured." end
	local webhookURL = Config.WebhookURL
	
	-- Construct the JSON payload for the webhook
	local logData = {
		["username"] = "RModular — LogService",
		["avatar_url"] = "https://avatars.githubusercontent.com/u/201587085?s=400&u=43827919c760b00a398b778b587bd81003c0ced7&v=4",
		["embeds"] = {{
			["title"] = "**New Log Entry**",
			["description"] = string.format("**Level**: %s\n**Message**: %s\n**Timestamp**: <t:%d>", 
				logEntry.Level, logEntry.Message, logEntry.Timestamp),
			["color"] = logEntry.Level == "Error" and 16711680 or logEntry.Level == "Warning" and 16753920 or 3066993
		}}
	}

	-- Encode data to JSON format
	local jsonData = HttpService:JSONEncode(logData)

	-- Attempt to send the log
	local success, errorMessage = pcall(function()
		HttpService:PostAsync(webhookURL, jsonData, Enum.HttpContentType.ApplicationJson)
	end)
	-- Handle request failure
	if not success then
		return false, errorMessage
	end

	return true
end

return Module
