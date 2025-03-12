export type LogType = 'Debug' | 'Info' | 'Warning' | 'Error' | 'Critical'

export type LogEntry = {
	Message: string,
	Level: LogType,
	Timestamp: number,
	Caller: string,
}

return {}
