using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using LuaInterface;

namespace TiinBot
{
	class LuaHandler
	{
		public Lua lua;

		public LuaHandler()
		{
			lua = new Lua();
			if (!Directory.Exists("Lua"))
			{
				Directory.CreateDirectory("Lua");
			}
			foreach (string filename in Directory.GetFiles("Lua"))
			{
				if (filename.EndsWith(".lua"))
				{
					try
					{
						lua.DoFile(filename);
					}
					catch (LuaException e)
					{
						Console.WriteLine(e.Message);
					}
				}
			}
		}

		public object Loadstring(String code)
		{
			try
			{
				lua.DoString(code);
			}
			catch (LuaException e)
			{
				return e;
			}
			return null;
		}
	}
}
