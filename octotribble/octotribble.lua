luanet.load_assembly("Octotribble")
luanet.load_assembly("Meebey.SmartIrc4net")

SendType = luanet.import_type("Meebey.SmartIrc4net.SendType")
Octotribble = luanet.import_type("Octotribble.Octotribble")
PermRegistry = luanet.import_type("Octotribble.PermRegistry")
irc = Octotribble.irc

plugins = {}

function create_plugin(id, func, t)
	if plugins[t]==nil then
		plugins[t] = {}
	end
	if plugins[t][id] then return nil end
	plugins[t][id]=func
	print("Added plugin "..id)
end

function sendNotice(target, message)
	Octotribble.SendNotice(target, message)
end

function startswith(self, piece)
	return string.sub(self, 1, string.len(piece)) == piece
end

function evt_channel_message(sender, evt)
	if plugins['channel_message']==nil then
		plugins['channel_message'] = {}
		return nil
	end
	for k,v in pairs(plugins['channel_message']) do
		if evt.Data.MessageArray[0]==(Octotribble.PREFIX..k) then
			oldprint = print
			print = function(m) Octotribble.SendMessage(evt.Data.Channel, m) end
			v(evt.Data)
			print = oldprint
			oldprint = nil
		end
	end
end
channel_message_handler = irc.OnChannelMessage:Add(evt_channel_message)

function reset()
	irc.OnChannelMessage:Remove(channel_message_handler)
end
