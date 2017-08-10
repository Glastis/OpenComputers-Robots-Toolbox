local utilities = {}

local function xor_bool(bool)
	return not bool
end
utilities.xor_bool = xor_bool

local function file_exists(filepath)
	local f

	f = io.open(filepath,"r")
	if f then
		io.close(f)
		return true
	end
	return false
end
utilities.file_exists = file_exists

local function download_file(id, filepath, force)
	if force then
		os.execute('pastebin -f get ' .. id .. ' ' .. filepath)
	else
		os.execute('pastebin get ' .. id .. ' ' .. filepath)
	end
end
utilities.download_file = download_file

local function check_dependencie(id, filepath)
	if not file_exists(filepath) then
		download_file(id, filepath)
		return false
	end
	return true
end
utilities.check_dependencie = check_dependencie

local function is_elem_in_list(list, elem)
	local i

	i = 1
	while i <= #list do
		if list[i] == elem then
			return true
		end
		i = i + 1
	end
	return false
end
utilities.is_elem_in_list = is_elem_in_list

return utilities