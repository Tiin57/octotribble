luanet.load_assembly("TiinBot")
luanet.load_assembly("Meebey.SmartIrc4net")

SendType = luanet.import_type("Meebey.SmartIrc4net.SendType")
TiinBot = luanet.import_type("TiinBot.TiinBot")

bot = TiinBot.irc
function print(msg, target)
	if not target then target="#tiin57" end
	bot:SendMessage(SendType.Message, target, tostring(msg))
end