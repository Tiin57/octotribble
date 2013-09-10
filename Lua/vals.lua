 function vals(t)
 	local x=""
 	for k, v in pairs(t) do
 		x=x.." | "..k..":"..tostring(v)
 	end
 	return x:sub(3)
 end