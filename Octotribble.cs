using System;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading;
using System.Collections;
using System.Collections.Generic;
using System.Reflection;
using Meebey.SmartIrc4net;

namespace TiinBot
{
	class TiinBot
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

		public static LuaHandler lua;
		public static IrcClient irc = new IrcClient();
		public static List<IEventHandler> handlers = new List<IEventHandler>();
		public static Dictionary<string, string> properties = new Dictionary<string, string>();

		public static void Main(string[] args)
		{
			Thread.CurrentThread.Name = "Main";

			irc.Encoding = System.Text.Encoding.UTF8;

			irc.SendDelay = 150;

			InitializeConfig();
			PermRegistry.Init();
			irc.ActiveChannelSyncing = true;
			var type = typeof(IEventHandler);
			var types = AppDomain.CurrentDomain.GetAssemblies().ToList()
				.SelectMany(s => s.GetTypes())
				.Where(p => type.IsAssignableFrom(p));
			foreach (Type t in types)
			{
				var constructor = t.GetConstructor(new Type[] { });
				if (constructor == null)
				{
					continue;
				}
				object impl = constructor.Invoke(new object[] { });
				if (impl is IEventHandler)
				{
					IEventHandler i = (IEventHandler)impl;
					handlers.Add(i);
					switch (i.GetEvent())
					{
						case EVT_AWAY:
							irc.OnAway += new AwayEventHandler(i.OnEvent);
							break;
						case EVT_BAN:
							irc.OnBan += new BanEventHandler(i.OnEvent);
							break;
						case EVT_CHANNEL_ACTION:
							irc.OnChannelAction += new ActionEventHandler(i.OnEvent);
							break;
						case EVT_CHANNEL_ACTIVE_SYNCED:
							irc.OnChannelActiveSynced += new IrcEventHandler(i.OnEvent);
							break;
						case EVT_CHANNEL_MESSAGE:
							irc.OnChannelMessage += new IrcEventHandler(i.OnEvent);
							break;
						case EVT_CHANNEL_MODE_CHANGE:
							irc.OnChannelModeChange += new IrcEventHandler(i.OnEvent);
							break;
						case EVT_CHANNEL_NOTICE:
							irc.OnChannelNotice += new IrcEventHandler(i.OnEvent);
							break;
						case EVT_CHANNEL_PASSIVE_SYNCED:
							irc.OnChannelPassiveSynced += new IrcEventHandler(i.OnEvent);
							break;
						case EVT_CTCP_REPLY:
							irc.OnCtcpReply += new CtcpEventHandler(i.OnEvent);
							break;
						case EVT_CTCP_REQUEST:
							irc.OnCtcpRequest += new CtcpEventHandler(i.OnEvent);
							break;
						case EVT_DEHALFOP:
							irc.OnDehalfop += new DehalfopEventHandler(i.OnEvent);
							break;
						case EVT_DEOP:
							irc.OnDeop += new DeopEventHandler(i.OnEvent);
							break;
						case EVT_DEVOICE:
							irc.OnDevoice += new DevoiceEventHandler(i.OnEvent);
							break;
						case EVT_ERROR:
							irc.OnError += new Meebey.SmartIrc4net.ErrorEventHandler(i.OnEvent);
							break;
						case EVT_ERROR_MESSAGE:
							irc.OnErrorMessage += new IrcEventHandler(i.OnEvent);
							break;
						case EVT_HALFOP:
							irc.OnHalfop += new HalfopEventHandler(i.OnEvent);
							break;
						case EVT_INVITE:
							irc.OnInvite += new InviteEventHandler(i.OnEvent);
							break;
						case EVT_JOIN:
							irc.OnJoin += new JoinEventHandler(i.OnEvent);
							break;
						case EVT_KICK:
							irc.OnKick += new KickEventHandler(i.OnEvent);
							break;
						case EVT_MODE_CHANGE:
							irc.OnModeChange += new IrcEventHandler(i.OnEvent);
							break;
						case EVT_MOTD:
							irc.OnMotd += new MotdEventHandler(i.OnEvent);
							break;
						case EVT_NAMES:
							irc.OnNames += new NamesEventHandler(i.OnEvent);
							break;
						case EVT_NICK_CHANGE:
							irc.OnNickChange += new NickChangeEventHandler(i.OnEvent);
							break;
						case EVT_NOW_AWAY:
							irc.OnNowAway += new IrcEventHandler(i.OnEvent);
							break;
						case EVT_OP:
							irc.OnOp += new OpEventHandler(i.OnEvent);
							break;
						case EVT_PART:
							irc.OnPart += new PartEventHandler(i.OnEvent);
							break;
						case EVT_PING:
							irc.OnPing += new PingEventHandler(i.OnEvent);
							break;
						case EVT_QUERY_ACTION:
							irc.OnQueryAction += new ActionEventHandler(i.OnEvent);
							break;
						case EVT_QUERY_MESSAGE:
							irc.OnQueryMessage += new IrcEventHandler(i.OnEvent);
							break;
						case EVT_QUERY_NOTICE:
							irc.OnQueryNotice += new IrcEventHandler(i.OnEvent);
							break;
						case EVT_QUIT:
							irc.OnQuit += new QuitEventHandler(i.OnEvent);
							break;
						case EVT_RAW_MESSAGE:
							irc.OnRawMessage += new IrcEventHandler(i.OnEvent);
							break;
						case EVT_TOPIC:
							irc.OnTopic += new TopicEventHandler(i.OnEvent);
							break;
						case EVT_TOPIC_CHANGE:
							irc.OnTopicChange += new TopicChangeEventHandler(i.OnEvent);
							break;
						case EVT_UNAWAY:
							irc.OnUnAway += new IrcEventHandler(i.OnEvent);
							break;
						case EVT_UNBAN:
							irc.OnUnban += new UnbanEventHandler(i.OnEvent);
							break;
						case EVT_USERMODE_CHANGE:
							irc.OnUserModeChange += new IrcEventHandler(i.OnEvent);
							break;
						case EVT_VOICE:
							irc.OnVoice += new VoiceEventHandler(i.OnEvent);
							break;
						case EVT_WHO:
							irc.OnWho += new WhoEventHandler(i.OnEvent);
							break;
					}
				}
			}
			lua = new LuaHandler();
			string[] serverlist = new string[] { properties["server"] };
			int port = 6667;
			string[] channels = properties["channels"].Split(',');
			try
			{
				irc.Connect(serverlist, port);
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
		public static void Exit()
		{
			System.Environment.Exit(0);
		}

		public static void InitializeConfig()
		{
			if (!File.Exists("octotribble.cfg"))
			{
				Console.WriteLine("Error: config does not exist.");
				File.Create("tiinbot.cfg");
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
	}
}
