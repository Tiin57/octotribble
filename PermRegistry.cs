using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Xml;

namespace TiinBot
{
	class PermRegistry
	{
		public static Dictionary<string, List<string>> permissions = new Dictionary<string, List<string>>();
		public static void Init()
		{
			foreach (string file in Directory.GetFiles("Permissions"))
			{
				if (file.EndsWith(".perm"))
				{
					string name1 = file.Split('/')[file.Split('/').Length - 1];
					string name = name1.Split('\\')[name1.Split('\\').Length - 1].Split('.')[0];
					string[] perms = File.ReadAllLines(file);
					if (!permissions.ContainsKey(name))
					{
						permissions.Add(name, perms.ToList<string>());
						Console.WriteLine("Added user " + name + ".");
					}
				}
			}
		}
		public static void AddPerm(string nick, string perm)
		{
			string file = "Permissions/" + nick + ".perm";
			if (!File.Exists(file))
			{
				File.Create(file);
			}
			StreamWriter sw = new StreamWriter(file, true);
			sw.WriteLine(perm);
			sw.Close();
			if (!permissions.ContainsKey(nick))
			{
				permissions.Add(nick, new List<string>());
			}
			permissions[nick].Add(perm);
		}
		public static bool HasPerm(string nick, string perm)
		{
			if (permissions.ContainsKey(nick))
			{
				string[] p = perm.Split('_');
				if (p.Length == 2)
				{
					if (permissions[nick].Contains(p[1]) || permissions[nick].Contains(p[0] + "_*") || permissions[nick].Contains("*"))
					{
						return true;
					}
				}
				else
				{
					if (permissions[nick].Contains(perm) || permissions[nick].Contains("*"))
					{
						return true;
					}
				}
			}
			return false;
		}
		public static void RemovePerm(string nick, string perm)
		{
			string file = "Permissions/" + nick + ".perm";
			if (!permissions.ContainsKey(nick))
			{
				return;
			}
			List<string> perms = File.ReadAllLines(file).ToList<string>();
			perms.Remove(perm);
			File.WriteAllLines(file, perms.ToArray<string>());
			permissions[nick].Remove(perm);
		}
	}
}
