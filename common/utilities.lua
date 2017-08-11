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

local function file_exists(filepath)
	local f

	f = io.open(filepath, "rb")
	if f then
		f:close()
	end
	return f ~= nil
end
utilities.file_exists = file_exists

local function read_file(filepath)
	local f
	local str

	f = io.open(filepath, 'rb')
	str = f:read('*all')
	f:close()
	return str
end
utilities.read_file = read_file

local function write_to_file(filepath, str, mode)
	local f

	if not mode then
		mode = "a"
	end
	f = io.open(filepath, mode)
	f:write(str)
	f:close()
end
utilities.write_to_file = write_to_file

local function split(str, separator)
	local t = {}
	local i

	i = 1
	for line in string.gmatch(str, "([^" .. separator .. "]+)") do
		t[i] = line
		i = i + 1
	end
	return t
end
utilities.split = split

local function debug_info(more, calltrace)
	if not more then
		more = " "
	end
	if calltrace then
		local trace

		trace = split(split(debug.traceback(), '\n')[3], '/')
		write_to_file("trace.log", '\n' .. trace[#trace] .. '\n' .. more .. '\n')
	else
		write_to_file("trace.log", more .. '\n')
	end
end
utilities.debug_info = debug_info

local function var_dump(var)
	if type(var) == 'table' then
		local s

		s = '{ '
		for k,v in pairs(var) do
			if type(k) ~= 'number' then
				k = '"' .. k .. '"'
			end
			s = s .. '\n[' .. k .. '] = ' .. var_dump(v) .. ','
		end
		return s .. '\n} '
	end
	return tostring(var)
end
utilities.var_dump = var_dump

return utilities