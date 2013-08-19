function chan(data)
	if PermRegistry.HasPerm(data.Nick, "chan_change") and data.MessageArray.Length==3 then
		if data.MessageArray[1]=="join" then
			irc:RfcJoin(data.MessageArray[2])
		elseif data.MessageArray[1]=="part" then
			irc:RfcPart(data.MessageArray[2])
		end
	elseif data.MessageArray.Length ~= 3 then
		sendNotice(data.Nick, "Usage: botperm <add | remove> <nick> <perm>")
	else
		sendNotice(data.Nick, "You do not have the permissions required.")
	end
end

create_plugin("channel", chan, "channel_message")