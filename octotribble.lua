luanet.load_assembly("Octotribble")
luanet.load_assembly("Meebey.SmartIrc4net")
require('lfs')
SendType = luanet.import_type("Meebey.SmartIrc4net.SendType")
Octotribble = luanet.import_type("Octotribble.Octotribble")
PermRegistry = {}
File = luanet.import_type("System.IO.File")
Directory = luanet.import_type("System.IO.Directory")
irc = Octotribble.irc
bot = irc

ignored = {}
os.exit=nil
plugins = {}
const_plugins = {}
permissions={}

function sleep(n)
	local t0 = os.clock()
	while os.clock()-t0 <= n do end
end

local function sanitize(str)
	n1 = str:split('/')[#(str:split('/'))]
	n2 = (n1:split('\\')[#(n1:split('\\'))]):split('.')[1]
	return n2
end

function file_exists(name)
	local f=io.open(name,"r")
	if f~=nil then
		io.close(f) 
		return true 
	else 
		return false 
	end
end

local function split(self, sep)
	local sep, fields = sep or ":", {}
	local pattern = string.format("([^%s]+)", sep)
	self:gsub(pattern, function(c) fields[#fields+1]=c end)
	fields.__index=fields
	return fields
end

local function endswith(self, End)
	return End=='' or string.sub(self, -(End:len()))==End
end

local function startswith(self, piece)
	return string.sub(self, 1, string.len(piece)) == piece
end

getmetatable("string").__index.split=split
getmetatable("string").__index.endswith=endswith
getmetatable("string").__index.startswith=startswith

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

function readfile(file)
	lines={}
	for line in io.lines(file) do
		lines[#lines+1]=line
	end
	return lines
end

function list(dir)
	z=""
	for k in lfs.dir(dir) do
		z=z.." "..k
	end
	return string.sub(z, 2)
end

function get_nickserv_user(nick)
	irc:WriteLine("WHO "..nick.." %na")
	resp = irc:ReadLine(true)
	split = resp:split(" ")
	if split[2]=="264" then print("264") return end
	if split[2]=="354" then
		if split[5] ~= ":End" then
			irc:ReadLine(true)
			return split[5]
		end
	end
	return nil
end

local function AddPerm(user, perm)
	user = get_nickserv_user(user)
	local file = "Permissions/"..user..".perm"
	if not permissions[user] then
		permissions[user]={}
	end
	if not permissions[user][perm] then
		permissions[user][perm]=true
	end
	if not (readfile(file))[perm] then
		appendfile(file, perm.."\n")
	end
	--print("Added "..perm.." to "..user)
end

local function ReloadPermsFile(file)
	user=sanitize(file)
	user=get_nickserv_user(user)
	if not user then
		print("User from "..file.." is nil.")
		return
	end
	if not file_exists(file) then
		print(file.." does not exist.")
		permissions[user]=nil
		return
	end
	perms={}
	for line in io.lines(file) do
		perms[line]=true
	end
	permissions[user]=perms
	--print("Reloaded "..user.."'s permissions.")
end

local function ReloadPerms(user)
	user = get_nickserv_user(user)
	ReloadPermsFile("Permissions/"..user..".perm")
end

local function HasPerm(user, perm)
	user = get_nickserv_user(user)
	if permissions[user] then
		p = perm:split("_")
		if #p==2 then
			if permissions[user][perm] or permissions[user][p[1].."_*"] or permissions[user]["*"] then
				return true
			end
		else
			if permissions[user][perm] or permissions[user]["*"] then
				return true
			end
		end
	else
		ReloadPerms(user)
		return HasPerm(user, perm)
	end
	return false
end

local function RemovePerm(user, perm)
	user = get_nickserv_user(user)
	file = "Permissions/"..user..".perm"
	if (not file_exists(file)) or (not permissions[user]) or (not permissions[user][perm]) then
		return
	end
	perms = {}
	for line in io.lines(file) do
		perms[line]=true
	end
	perms[perm]=nil
	str = ""
	for k,v in pairs(perms) do
		str=str..k.."\n"
	end
	writefile(file, str)
	permissions[user][perm]=nil
	--print("Removed "..perm.." from "..user)
end

local function Init()
	permissions={}
	for file in lfs.dir("Permissions") do
		if file:endswith(".perm") then
			o,e = pcall(ReloadPermsFile, "Permissions/"..file)
			if not o then
				return false, e
			end
			--print("Loaded permissions file "..file)
		end
	end
	return true
end

PermRegistry.Init=Init
PermRegistry.AddPerm=AddPerm
PermRegistry.HasPerm=HasPerm
PermRegistry.RemovePerm=RemovePerm
PermRegistry.ReloadPerms=ReloadPerms
PermRegistry.ReloadPermsFile=ReloadPermsFile

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
	Octotribble.SendNotice(target, tostring(message))
end

function sendAction(target, action)
	Octotribble.SendAction(target, tostring(action))
end

function sendMessage(target, message)
	Octotribble.SendMessage(target, tostring(message))
end

plugins['private_notice']={}
function evt_private_notice(sender, evt)
	oldprint=print
	print = function(m) Octotribble.SendNotice(evt.Data.Nick, tostring(m)) end
	_G['data']=evt.Data
	for k,v in pairs(plugins['private_notice']) do
		o,e = pcall(v, evt.Data)
		if not o then
			oldprint("Exception in plugin: "..e)
		end
	end
	print=oldprint
	oldprint=nil
end
plugins['channel_kick']={}
function evt_kick(sender, evt)
	data={Kicker=evt.Who, Kicked=evt.Whom, Channel=evt.Channel, Reason=evt.KickReason}
	oldprint = print
	print = function(m) Octotribble.SendMessage(evt.Channel, tostring(m)) end
	_G['data']=data
	for k,v in pairs(plugins['channel_kick']) do
		o,e = pcall(v, data)
		if not o then
			print("Exception in plugin: "..e)
		end
	end
	print=oldprint
	oldprint=nil
end
plugins['channel_ban']={}
function evt_ban(sender, evt)
	data={Banned=evt.Hostmask, Banner=evt.Who, Channel=evt.Channel}
	oldprint = print
	print = function(m) Octotribble.SendMessage(evt.Channel, tostring(m)) end
	_G['data']=data
	for k,v in pairs(plugins['channel_ban']) do
		o,e = pcall(v, data)
		if not o then
			print("Exception in plugin: "..e)
		end
	end
	print=oldprint
	oldprint=nil
end
plugins['channel_action']={}
function evt_action(sender, evt)
	if plugins['channel_action']==nil then
		plugins['channel_action']={}
		return nil
	end
	if ignored[evt.Data.Nick] then
		return nil
	end
	_G['data']=evt.Data
	oldprint = print
	print = function(m) Octotribble.SendMessage(evt.Channel, tostring(m)) end
	for k,v in pairs(plugins['channel_action']) do
		o,e = pcall(v, evt.Data)
		if not o then
			print("Exception in plugin: "..e)
		end
	end
	print=oldprint
	oldprint=nil
end
plugins['private_message']={}
function evt_private_message(sender, evt)
	if plugins['private_message']==nil then
		plugins['private_message'] = {}
		return nil
	end
	if ignored[evt.Data.Nick] then
		return nil
	end
	oldprint = print
	print = function(m) Octotribble.SendMessage(evt.Data.Nick, tostring(m)) end
	msg = tostring(evt.Data.Message)
	msg=(msg:gsub("^%s*(.-)%s*$", "%1"))
	msgarray={}
	for i=0, tonumber(evt.Data.MessageArray.Length-1) do
		msgarray[i]=evt.Data.MessageArray[i]
	end
	msgarray[#msgarray]=(tostring(msgarray[#msgarray])):gsub("^%s*(.-)%s*$", "%1")
	msgarray['Length']=#msgarray+1
	data={
		From=evt.Data.From,
		Host=evt.Data.Host,
		Ident=evt.Data.Ident,
		Irc=evt.Data.Irc,
		Message=msg,
		MessageArray=msgarray,
		Nick=evt.Data.Nick,
		RawMessage=evt.Data.RawMessage,
		RawMessageArray=evt.Data.RawMessageArray,
		ReplyCode=evt.Data.ReplyCode,
		Type=evt.Data.Type
	}
	_G['data'] = data
	for k,v in pairs(plugins['private_message']) do
		if evt.Data.MessageArray[0]==(Octotribble.PREFIX..k) then
			o,e = pcall(v, data)
			if not o and e then
				print("Exception in plugin: "..tostring(e))
			end
		end
		if const_plugins[k] then
			o,e = pcall(v, data)
			if not o then
				print("Exception in plugin: "..tostring(e))
			end
		end
	end
	print=oldprint
	oldprint = nil
end
plugins['channel_message']={}
function evt_channel_message(sender, evt)
	if plugins['channel_message']==nil then
		plugins['channel_message'] = {}
		return nil
	end
	if ignored[evt.Data.Nick] then
		return nil
	end
	oldprint = print
	print = function(m) Octotribble.SendMessage(evt.Data.Channel, tostring(m)) end
	msg = tostring(evt.Data.Message)
	msg=(msg:gsub("^%s*(.-)%s*$", "%1"))
	msgarray={}
	for i=0, tonumber(evt.Data.MessageArray.Length-1) do
		msgarray[i]=evt.Data.MessageArray[i]
	end
	msgarray[#msgarray]=(tostring(msgarray[#msgarray])):gsub("^%s*(.-)%s*$", "%1")
	msgarray['Length']=#msgarray+1
	data={
		Channel=evt.Data.Channel,
		From=evt.Data.From,
		Host=evt.Data.Host,
		Ident=evt.Data.Ident,
		Irc=evt.Data.Irc,
		Message=msg,
		MessageArray=msgarray,
		Nick=evt.Data.Nick,
		RawMessage=evt.Data.RawMessage,
		RawMessageArray=evt.Data.RawMessageArray,
		ReplyCode=evt.Data.ReplyCode,
		Type=evt.Data.Type
	}
	_G['data'] = data
	for k,v in pairs(plugins['channel_message']) do
		if evt.Data.MessageArray[0]==(Octotribble.PREFIX..k) then
			o,e = pcall(v, data)
			if not o and e then
				print("Exception in plugin: "..tostring(e))
			end
		end
		if const_plugins[k] then
			o,e = pcall(v, data)
			if not o then
				print("Exception in plugin: "..tostring(e))
			end
		end
	end
	print=oldprint
	oldprint = nil
end
c_action = "channel_action"
c_message = "channel_message"
c_kick = "channel_kick"
c_ban = "channel_ban"
p_message = "private_message"
p_notice = "private_notice"
channel_message_handler = irc.OnChannelMessage:Add(evt_channel_message)
action_handler = irc.OnChannelAction:Add(evt_action)
kick_handler = irc.OnKick:Add(evt_kick)
ban_handler = irc.OnBan:Add(evt_ban)
private_message_handler = irc.OnQueryMessage:Add(evt_private_message)
private_notice_handler = irc.OnQueryNotice:Add(evt_private_notice)

--o,e = PermRegistry.Init()
--if not o then
--	print("Error in PermRegistry: "..tostring(e))
--end

function reset()
	irc.OnChannelMessage:Remove(channel_message_handler)
	irc.OnPing:Remove(pong_event_handler)
	irc.OnChannelAction:Remove(action_handler)
	irc.OnKick:Remove(kick_handler)
	irc.OnBan:Remove(ban_handler)
	irc.OnQueryMessage:Remove(private_message_handler)
	irc.OnQueryNotice:Remove(private_notice_handler)
end

cplugin = create_plugin
