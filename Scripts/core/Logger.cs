using Godot;
using System;

namespace Game.Core{
	public static class Logger
	{
		public static void Log(LogLevel level, params object[] message)
		{
			var dateTime = DateTime.Now;
			string formattedDateTime = dateTime.ToString("yyyy-MM-dd HH:mm:ss");
			string formattedMessage = $"[{formattedDateTime}][{level}] {string.Join(" ", message)}";

			string color = "CYAN";
			switch (level)
			{
				case LogLevel.Debug:
					color = "WHITE";
					break;
				case LogLevel.Info:
					color = "CYAN";
					break;
				case LogLevel.Warning:
					color = "YELLOW";
					break;
				case LogLevel.Error:
					color = "RED";
					break;
			}

			GD.PrintRich([$"[color={color}]{formattedMessage}[/color]", ..message]);
		}

		public static void Debug(params object[] message)
		{
			Log(LogLevel.Debug, message);
		}
		public static void Info(params object[] message)
		{
			Log(LogLevel.Info, message);
		}
		public static void Warning(params object[] message)
		{
			Log(LogLevel.Warning, message);
		}
		public static void Error(params object[] message)
		{
			Log(LogLevel.Error, message);
		}
	}
}
