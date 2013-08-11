using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Meebey.SmartIrc4net;
using LuaInterface;

namespace TiinBot.Plugins
{
	class ChannelMessage : IEventHandler
	{
		public string GetEvent()
		{
			return TiinBot.EVT_CHANNEL_MESSAGE;
		}

		public void OnEvent(object sender, IrcEventArgs args)
		{
			string nick = args.Data.Nick;
			string[] msg = args.Data.MessageArray;
			string channel = args.Data.Channel;
			string rawcmd = msg[0].Substring(TiinBot.PREFIX.Length);
			IrcClient irc = TiinBot.irc;

			if (rawcmd == "lua" && PermRegistry.HasPerm(nick, "lua_lua"))
			{
				LoadString(args);
				return;
			}
			if (rawcmd == "chanman")
			{
				if (msg[1] == "op" && PermRegistry.HasPerm(nick, "chan_op"))
					irc.Op(channel, msg[2]);
				else if (msg[1] == "deop" && PermRegistry.HasPerm(nick, "chan_deop"))
					irc.Deop(channel, msg[2]);
				else if (msg[1] == "voice" && PermRegistry.HasPerm(nick, "chan_voice"))
					irc.Voice(channel, msg[2]);
				else if (msg[1] == "devoice" && PermRegistry.HasPerm(nick, "chan_devoice"))
					irc.Devoice(channel, msg[2]);
				else if (msg[1] == "kick" && PermRegistry.HasPerm(nick, "chan_kick"))
					irc.RfcKick(channel, msg[2], "Kick ordered by " + nick);
				else if (msg[1] == "ban" && PermRegistry.HasPerm(nick, "chan_ban"))
					irc.Ban(channel, msg[2]);
				else if (msg[1] == "unban" && PermRegistry.HasPerm(nick, "chan_unban"))
					irc.Unban(channel, msg[2]);
				else if (msg[1] == "kickban" && PermRegistry.HasPerm(nick, "chan_kickban"))
				{
					irc.Ban(channel, "*!*@*." + irc.GetIrcUser(msg[2]).Host);
					irc.RfcKick(channel, msg[2], "Kickban ordered by " + nick);
				}
				return;
			}
			switch (msg.Length)
			{
				case 0:
					break;
				case 1:
					if (rawcmd == "setluachan" && PermRegistry.HasPerm(nick, "lua_setchan"))
						TiinBot.lua.lua.DoString("currentChannel='" + channel + "'");
					else if (rawcmd == "reload" && PermRegistry.HasPerm(nick, "bot_reload"))
					{
						
					}
					break;
				case 2:
					if (rawcmd == "setluachan" && PermRegistry.HasPerm(nick, "lua_setchan"))
						TiinBot.lua.lua.DoString("currentChannel='" + msg[1] + "'");
					else if (rawcmd == "join" && PermRegistry.HasPerm(nick, "chan_join"))
						irc.RfcJoin(msg[1]);
					else if (rawcmd == "part" && PermRegistry.HasPerm(nick, "chan_part"))
						irc.RfcPart(msg[1]);
					else if (rawcmd == "botop" && PermRegistry.HasPerm(nick, "perm_op"))
						PermRegistry.AddPerm(msg[1], "*");
					break;
				case 4:
					if (rawcmd == "botperm" && PermRegistry.HasPerm(nick, "perm_modify"))
					{
						if (msg[1] == "add")
							PermRegistry.AddPerm(msg[2], msg[3]);
						else if (msg[1] == "remove")
							PermRegistry.RemovePerm(msg[2], msg[3]);
					}
					break;
			}
		}

		private void LoadString(IrcEventArgs args)
		{
			string code = "";
			for (int i=1; i<args.Data.MessageArray.Length; i++)
			{
				code += args.Data.MessageArray[i] + " ";
			}
			object result;
			if ((result = TiinBot.lua.Loadstring(code)) is LuaException)
			{
				LuaException e = (LuaException)result;
				TiinBot.irc.SendMessage(SendType.Notice, args.Data.Nick, "Lua code errored:");
				TiinBot.irc.SendMessage(SendType.Notice, args.Data.Nick, e.Message);
			}
			else
			{
				TiinBot.irc.SendMessage(SendType.Notice, args.Data.Nick, "Lua code was run successfully.");
			}
		}
	}
}
