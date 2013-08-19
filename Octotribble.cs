//css_reference lib/Meebey.SmartIrc4Net.dll
//css_reference lib/LuaInterface.dll
//css_import PermRegistry
using System;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading;
using System.Collections;
using System.Collections.Generic;
using System.Reflection;
using Meebey.SmartIrc4net;
using LuaInterface;

namespace Octotribble
{
	class Octotribble
	{
		public const string PREFIX = "~";

		public const string EVT_AWAY = "AWAY";
		public const string EVT_BAN = "BAN";
		public const string EVT_CHANNEL_ACTION = "CHANNEL_ACTION";
		public const string EVT_CHANNEL_ACTIVE_SYNCED = "CHANNEL_ACTIVE_SYNCED";
		public const string EVT_CHANNEL_MESSAGE = "CHANNEL_MESSAGE";
		public const string EVT_CHANNEL_MODE_CHANGE = "CHANNEL_MODE_CHANGE";
		public const string EVT_CHANNEL_NOTICE = "CHANNEL_NOTICE";
		public const string EVT_CHANNEL_PASSIVE_SYNCED = "CHANNEL_PASSIVE_SYNCED";
		public const string EVT_CTCP_REPLY = "CTCP_REPLY";
		public const string EVT_CTCP_REQUEST = "CTCP_REQUEST";
		public const string EVT_DEHALFOP = "DEHALFOP";
		public const string EVT_DEOP = "DEOP";
		public const string EVT_DEVOICE = "DEVOICE";
		public const string EVT_ERROR = "ERROR";
		public const string EVT_ERROR_MESSAGE = "ERROR_MESSAGE";
		public const string EVT_HALFOP = "HALFOP";
		public const string EVT_INVITE = "INVITE";
		public const string EVT_JOIN = "JOIN";
		public const string EVT_KICK = "KICK";
		public const string EVT_MODE_CHANGE = "MODE_CHANGE";
		public const string EVT_MOTD = "MOTD";
		public const string EVT_NAMES = "NAMES";
		public const string EVT_NICK_CHANGE = "NICK_CHANGE";
		public const string EVT_NOW_AWAY = "NOW_AWAY";
		public const string EVT_OP = "OP";
		public const string EVT_PART = "PART";
		public const string EVT_PING = "PING";
		public const string EVT_QUERY_ACTION = "QUERY_ACTION";
		public const string EVT_QUERY_MESSAGE = "QUERY_MESSAGE";
		public const string EVT_QUERY_NOTICE = "QUERY_NOTICE";
		public const string EVT_QUIT = "QUIT";
		public const string EVT_RAW_MESSAGE = "RAW_MESSAGE";
		public const string EVT_TOPIC = "TOPIC";
		public const string EVT_TOPIC_CHANGE = "TOPIC_CHANGE";
		public const string EVT_UNAWAY = "UNAWAY";
		public const string EVT_UNBAN = "UNBAN";
		public const string EVT_USERMODE_CHANGE = "USERMODE_CHANGE";
		public const string EVT_VOICE = "VOICE";
		public const string EVT_WHO = "WHO";

		public static IrcClient irc = new IrcClient();
		public static Dictionary<string, string> properties = new Dictionary<string, string>();
		public static Lua lua = new Lua();

		public static void Exit()
		{
			System.Environment.Exit(0);
		}

		public static void SendMessage(string target, string message)
		{
			irc.SendMessage(SendType.Message, target, message);
		}

		public static void SendNotice(string target, string message)
		{
			irc.SendMessage(SendType.Notice, target, message);
		}
		public static void ResetLua()
		{
			lua = new Lua();
			LoadLuaScripts();
		}

		public static void LoadLuaScripts()
		{
			if (File.Exists("octotribble.lua"))
			{
				lua.DoFile("octotribble.lua");
			}
			if (!Directory.Exists("Lua"))
			{
				Directory.CreateDirectory("Lua");
			}
			foreach (string i in Directory.GetFiles("Lua"))
			{
				if (i.EndsWith(".lua"))
				{
					try
					{
						lua.DoFile(i);
					}
					catch (Exception e)
					{
						Console.WriteLine(e.Message);
					}
				}
			}
		}

		public static void InitializeConfig()
		{
			if (!File.Exists("octotribble.cfg"))
			{
				Console.WriteLine("Error: config does not exist.");
				File.Create("octotribble.cfg");
				Exit();
			}
			string[] lines = File.ReadAllLines("octotribble.cfg");
			foreach (string i in lines)
			{
				string[] a = i.Split(':');
				if (a.Length < 2)
				{
					continue;
				}
				properties.Add(a[0], a[1]);
			}

			if (!Directory.Exists("Permissions"))
			{
				Directory.CreateDirectory("Permissions");
			}
		}

		public static void Main(string[] args)
		{
			Thread.CurrentThread.Name = "Main";

			irc.Encoding = System.Text.Encoding.UTF8;

			irc.SendDelay = 10;

			InitializeConfig();
			PermRegistry.Init();
			LoadLuaScripts();
			irc.ActiveChannelSyncing = true;
			
			string[] serverlist = new string[] { properties["server"] };
			int port = 6667;
			string[] channels = properties["channels"].Split(',');
			try
			{
				irc.Connect(serverlist, port);
				Console.WriteLine("Connected!");
			}
			catch (ConnectionException ex)
			{
				Console.WriteLine("Couldn't connect! " + ex.Message);
				//Exit();
			}
			try
			{
				irc.Login(properties["nickname"], "Octotribble by tiin57");

				foreach (string i in channels)
				{
					irc.RfcJoin(i);
					Console.WriteLine("Joined "+i);
				}

				irc.SendMessage(SendType.Message, "NickServ", "identify "+properties["nickserv"]);

				irc.Listen();

				irc.Disconnect();
			}
			catch (ConnectionException ex)
			{
				Console.WriteLine(ex.Message);
				Console.WriteLine(ex.StackTrace);
			}
			catch (Exception ex)
			{
				Console.WriteLine(ex.Message);
				Console.WriteLine(ex.StackTrace);
			}
		}
	}
}