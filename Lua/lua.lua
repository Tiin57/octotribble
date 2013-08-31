envs = {}
locked = {}
local count = 0
local function create_env(isadmin)
	g={}
	if isadmin then
		for k, v in pairs(_G) do
			g[k]=v
		end
	else
		g['assert']=assert
		g['string']=string
		g['string']['dump']=nil
		g['string']['rep']=nil
		g['os']={}
		g['os']['clock']=os.clock
		g['os']['difftime']=os.difftime
		g['os']['time']=os.time
		g['ipairs']=ipairs
		g['next']=next
		g['pairs']=pairs
		g['pcall']=pcall
		g['print']=print
		g['select']=select
		g['tonumber']=tonumber
		g['tostring']=tostring
		g['type']=type
		g['unpack']=unpack
		g['_VERSION']=_VERSION
		g['xpcall']=xpcall
		g['table']=table
		g['math']=math
	end
	
	g['_G']=g
	g['__index']=g
	return g
end

local function fix_env_default()
	getmetatable("string").__index.rep=nil
	getmetatable("string").__index.match=nil
end
local function update_env(env)
	_env = {}
	for k, v in pairs(_G) do
		_env[k]=v
	end
	for k,v in pairs(env) do
		_env[k]=v
	end
	return _env
end

function lua_new(data)
	if PermRegistry.HasPerm(data.Nick, "lua_new") then
		if envs[data.Nick] ~= nil and not locked[data.Nick] then
			sendNotice(data.Nick, "You already have a Lua environment!")
			return nil
		end
		envs[data.Nick]=create_env(PermRegistry.HasPerm(data.Nick, "lua_admin"))
		if not PermRegistry.HasPerm(data.Nick, "lua_admin") then
			envs[data.Nick]['getmetatable']=_G['getmetatable']
			setfenv(fix_env_default, envs[data.Nick])
			fix_env_default()
			envs[data.Nick]['getmetatable']=nil
		end
		sendNotice(data.Nick, "Lua env created.")
	elseif locked[data.Nick] then
		sendNotice(data.Nick, "Your Lua access has been revoked.")
	else
		sendNotice(data.Nick, "You do not have the permissions required.")
	end
end

function lua_dispose(data)
	if PermRegistry.HasPerm(data.Nick, "lua_dispose") then
		if data.MessageArray.Length==2 and PermRegistry.HasPerm(data.Nick, "lua_disposeother") then
			envs[data.MessageArray[1]]=nil
			sendNotice(data.Nick, "Disposed "..data.MessageArray[1].."'s VM.")
			return nil
		end
		envs[data.Nick]=nil
		sendNotice(data.Nick, "Disposed your VM.")
	else
		sendNotice(data.Nick, "You do not have the permissions required.")
	end
end

function lua_global(data)
	if PermRegistry.HasPerm(data.Nick, "lua_global") then
		f, e = loadstring(string.sub(data.Message, 7))
		if not f then
			sendNotice(data.Nick, "Exception raised at loadstring: "..tostring(e))
			return nil
		end
		_G['f']=f
		_count = math.random(1900, 2100)
		debug.sethook(function() if count > _count then count = 0 error("Too long without stopping") else count = count +1 end end, 'l')
		o,e = pcall(f)
		debug.sethook()
		_G['f']=nil
		if not o then
			sendNotice(data.Nick, "Exception raised at pcall: "..tostring(e))
			return nil
		end
	else
		sendNotice("You do not have the permissions required.")
	end
end

function lua_lock(data)
	if PermRegistry.HasPerm(data.Nick, "lua_lock") and data.MessageArray.Length==2 then
		if envs[data.MessageArray[1]] ~= nil then
			envs[data.MessageArray[1]] = nil
			sendNotice(data.Nick, "Locked "..data.MessageArray[1].."'s Lua access and destroyed their VM.")
			sendNotice(data.MessageArray[1], "Your Lua access has been locked and your VM has been destroyed by "..data.Nick)
		end
	else
		sendNotice("You do not have the permissions required.")
	end
end

function lua_copyvm(data)
	if PermRegistry.HasPerm(data.Nick, "lua_copyvm") and data.MessageArray.Length==2 then
		if envs[data.MessageArray[1]] ~= nil then
			envs[data.Nick] = envs[data.MessageArray[1]]
			sendNotice(data.Nick, "Copied "..data.MessageArray[1].."'s VM to yours.")
		end
	else
		sendNotice("You do not have the permissions required.")
	end
end

function lua_run(data)
	if PermRegistry.HasPerm(data.Nick, "lua_run") then
		if not envs[data.Nick] then
			lua_new(data)
		end
		envs[data.Nick]['data']=data
		envs[data.Nick]['print']=print
		f, e = loadstring(string.sub(data.Message, 6))
		if not f then
			sendNotice(data.Nick, "Exception raised at loadstring: "..tostring(e))
			return nil
		end
		setfenv(f, envs[data.Nick])
		_G['f']=f
		_count = math.random(1900, 2100)
		debug.sethook(function() if count > _count then count = 0 error("Too long without stopping") else count = count +1 end end, 'l')
		o,e = pcall(f)
		debug.sethook()
		if not o then
			sendNotice(data.Nick, "Exception raised at pcall: "..tostring(e))
		end
		_G['f']=nil
	else
		sendNotice("You do not have the permissions required.")
	end
end

cplugin("lua", lua_run, c_message)
cplugin("luanew", lua_new, c_message)
cplugin("luag", lua_global, c_message)
cplugin("luadispose", lua_dispose, c_message)
cplugin("lualock", lua_lock, c_message)
cplugin("luacopy", lua_copyvm, c_message)