function ignore(data)
	if PermRegistry.HasPerm(data.Nick, "gen_ignore") and data.MessageArray.Length==2 then
		ignored[data.MessageArray[1]]=true
		sendNotice(data.Nick, "Ignored "..data.MessageArray[1])
	end
end

cplugin("ignore", ignore, c_message)