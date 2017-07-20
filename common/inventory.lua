local component = require("component")

function select_item_failsafe(item, trymax, meta)
	local try = 0

	while not select_item(item, meta) do
		if meta then
			print("Can't select " .. item .. " with meta: " .. meta .. "\nWaiting 30 secs before retrying.")
		else
			print("Can't select " .. item .. "\nWaiting 30 secs before retrying.")
		end
		try = try + 1
		if try > trymax then
			computer.shutdown()
		end
		os.sleep(30)
	end
end

function select_fuel()
	while item_amount("minecraft:coal", 1) < 16 do
		if not get_fuel_from_enderchest(amount) then
			print("Fail to retreive fuel from enderchest. Retring in 30 secondes...")
			os.sleep(30)
		end
	end
	select_item("minecraft:coal", 1)
	select_item("minecraft:coal", 1)
	return true
end
