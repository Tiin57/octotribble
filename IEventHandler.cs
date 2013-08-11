using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Meebey.SmartIrc4net;

namespace TiinBot
{
	interface IEventHandler
	{
		void OnEvent(object sender, IrcEventArgs evt);
		string GetEvent();
	}
}
