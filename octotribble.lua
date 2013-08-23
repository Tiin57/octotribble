luanet.load_assembly("Octotribble")
luanet.load_assembly("Meebey.SmartIrc4net")

SendType = luanet.import_type("Meebey.SmartIrc4net.SendType")
Octotribble = luanet.import_type("Octotribble.Octotribble")
PermRegistry = luanet.import_type("Octotribble.PermRegistry")
File = luanet.import_type("System.IO.File")
Directory = luanet.import_type("System.IO.Directory")

irc = Octotribble.irc

os.exit=nil
plugins = {}
const_plugins = {}

function create_plugin(id, func, t, const)
	if plugins[t]==nil then
		plugins[t] = {}
	end
	if const==nil then const=false end
	if plugins[t][id] then return nil end
	plugins[t][id]=func
	const_plugins[id] = const
	print("Added plugin "..id)
end

function sendNotice(target, message)
	Octotribble.SendNotice(target, message)
end

function sendAction(target, action)
	Octotribble.SendAction(target, action)
end

function sendMessage(target, message)
	Octotribble.SendMessage(target, message)
end

function startswith(self, piece)
	return string.sub(self, 1, string.len(piece)) == piece
end

function explore(t)
	x=""
	for k in pairs(t) do
		x=x.." "..tostring(k)
	end
	return x
end

function writefile(file, data)
	f = io.open(file, "w")
	if not f then return false end
	f:write(tostring(data))
	f:flush()
	f:close()
end

function appendfile(file, data)
	f = io.open(file, "a")
	if not f then return false end
	f:write(tostring(data))
	f:flush()
	f:close()
end

function list(dir)
	z=""
	for k in (io.popen("ls "..dir):read("*all")):gmatch("[^\r\n]+") do
		z=z.." "..k
	end
	return string.sub(z, 2)
end
plugins['channel_kick']={}
function evt_kick(sender, evt)
	for k,v in pairs(plugins['channel_kick']) do
		data={Kicker=evt.Who, Kicked=evt.Whom, Channel=evt.Channel, Reason=evt.KickReason}
		oldprint = print
		print = function(m) Octotribble.SendMessage(evt.Channel, tostring(m)) end
		_G['data']=data
		v(data)
		print=oldprint
		oldprint=nil
	end
end
plugins['channel_ban']={}
function evt_ban(sender, evt)
	for k,v in pairs(plugins['channel_ban']) do
		data={Banned=evt.Hostmask, Banner=evt.Who, Channel=evt.Channel}
		oldprint = print
		print = function(m) Octotribble.SendMessage(evt.Channel, tostring(m)) end
		_G['data']=data
		v(data)
		print=oldprint
		oldprint=nil
	end
end
plugins['channel_action']={}
function evt_action(sender, evt)
	if plugins['channel_action']==nil then
		plugins['channel_action']={}
		return nil
	end
	for k,v in pairs(plugins['channel_action']) do
		_G['data']=evt.Data
		v(evt.Data)
	end
end
plugins['channel_message']={}
function evt_channel_message(sender, evt)
	if plugins['channel_message']==nil then
		plugins['channel_message'] = {}
		return nil
	end
	for k,v in pairs(plugins['channel_message']) do
		if evt.Data.MessageArray[0]==(Octotribble.PREFIX..k) then
			oldprint = print
			print = function(m) Octotribble.SendMessage(evt.Data.Channel, tostring(m)) end
			_G['data'] = evt.Data
			v(evt.Data)
			print = oldprint
			oldprint = nil
		end
		if const_plugins[k] then
			oldprint = print
			print = function(m) Octotribble.SendMessage(evt.Data.Channel, tostring(m)) end
			o,e = pcall(v, evt.Data)
			if not o then
				print("Exception: "..e)
			end
			print = oldprint
			oldprint = nil
		end
	end
end
c_action = "channel_action"
c_message= "channel_message"
c_kick = "channel_kick"
c_ban = "channel_ban"
channel_message_handler = irc.OnChannelMessage:Add(evt_channel_message)
action_handler = irc.OnChannelAction:Add(evt_action)
kick_handler = irc.OnKick:Add(evt_kick)
ban_handler = irc.OnBan:Add(evt_ban)
function reset()
	irc.OnChannelMessage:Remove(channel_message_handler)
	irc.OnPing:Remove(pong_event_handler)
	irc.OnChannelAction:Remove(action_handler)
	irc.OnKick:Remove(kick_handler)
	irc.OnBan:Remove(ban_handler)
end

cplugin = create_plugin
