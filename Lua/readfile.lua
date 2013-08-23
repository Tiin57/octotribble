function readfile(data)
	if PermRegistry.HasPerm(data.Nick, "io_readfile") and File.Exists(data.MessageArray[1]) then
		lines=""
		for line in io.lines(data.MessageArray[1]) do
			lines=lines.." "..line
		end
		sendNotice(data.Nick, lines)
	end
end
create_plugin("readfile", readfile, c_message)
