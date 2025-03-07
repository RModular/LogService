export type LogEntry = {
	Message: string,
	Level: 'Info' | 'Warning' | 'Error',
	Timestamp: number
}

export type LogType = 'Info' | 'Warning' | 'Error'

export type LogService = {
	FireLog: (self: LogService, message: string, level: string) -> (),
	GetLogHistory: (self: LogService) -> {LogEntry},
	ClearLogHistory: (self: LogService) -> (),
	SetMaxLogEntries: (self: LogService, limit: number) -> (),
	SetLogFilter: (self: LogService, levels: {string}) -> (),
	LogToFile: (self: LogService, filename: string) -> (),
}

return {}
