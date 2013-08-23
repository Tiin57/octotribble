//css_reference AIMLbot.dll

using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using AIMLbot;

namespace FuzzyWallhack
{
	class FuzzyWallhackBot
	{
		public Bot bot;
		public Dictionary<string, User> users;
		public FuzzyWallhackBot()
		{
			bot = new Bot();
			users = new Dictionary<string, User>();
		}

		public void Initialize()
		{
			bot.loadSettings();
			bot.isAcceptingUserInput = false;
			bot.loadAIMLFromFiles();
			bot.isAcceptingUserInput = true;
		}

		public String GetOutput(String input, String username)
		{
			if (!users.ContainsKey(username))
				users[username] = new User(username, bot);
			Request r = new Request(input, users[username], bot);
			Result res = bot.Chat(r);
			return res.Output;
		}
	}
}
