function cmd_write(data)
	if PermRegistry.HasPerm(data.Nick, "io_writefile") then
		writefile(data.MessageArray[1], string.sub(data.Message, string.len("~writefile")+string.len(data.MessageArray[1])+2))
	end
end
function cmd_append(data)
	if PermRegistry.HasPerm(data.Nick, "io_appendfile") then
		appendfile(data.MessageArray[1], string.sub(data.Message, string.len("~appendfile")+string.len(data.MessageArray[1])+2))
	end
end
cplugin("writefile", cmd_write, c_message)
cplugin("appendfile", cmd_append, c_message)