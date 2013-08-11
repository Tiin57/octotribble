using System;
using System.Collections;
using System.Collections.Generic;
using System.Collections.Specialized;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using LuaInterface;
using Meebey.SmartIrc4net;

namespace TiinBot.Plugins
{
	class ActionChannel : IEventHandler
	{
		public string GetEvent()
		{
			return TiinBot.EVT_CHANNEL_ACTION;
		}
		public void OnEvent(object sender, IrcEventArgs args)
		{
			var funcs = TiinBot.lua.lua.GetTable("lua_handlers");
			foreach (DictionaryEntry member in funcs)
			{
				
			}
		}
	}
}
