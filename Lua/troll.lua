trolled = {}
function addtroll(data)
	if PermRegistry.HasPerm(data.Nick, "troll_modify") and data.MessageArray.Length==2 then
		table.insert(trolled, data.MessageArray[1])
	elseif data.MessageArray.Length ~= 2 then
		sendNotice(data.Nick, "Usage: addtroll <nick>")
	else
		sendNotice(data.Nick, "You do not have the permissions required.")
	end
end
create_plugin("addtroll", addtroll, "channel_message")

function troll(data)
	for k,v in pairs(trolled) do
		if v==data.Nick then
			print("Herp derp "..v)
		end
	end
end
create_plugin("troll", troll, "channel_message", true)