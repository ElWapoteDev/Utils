local Http = game:GetService("HttpService");
local fetch = ((syn and syn.request) or request or 
	(function(options)
		return Http:RequestAsync(options);
	end));

local Utils = {};

function Utils.CleanJSON(Respuesta)
	local UltimaTabla = Respuesta:match("%b{}")
	for Tabla in Respuesta:gmatch("%b{}") do
		UltimaTabla = Tabla
	end
	return UltimaTabla;
end;

function Utils.MiAssert(valor, mensaje)
	if not valor then
		warn(mensaje..' The script has stopped running. Please check the external console for further details.') ;
	end;

	assert(valor, mensaje);
end;

function Utils.GenerarStatus(statu: boolean, cuerpo: any)
	local Estado = {};

	Estado['Status'] = statu;
	Estado['Body'] = cuerpo;

	return Estado;
end;

function Utils.printTable(tbl)
	if type(tbl) ~= "table" then
		print(tostring(tbl))
		return
	end

	local function printTableHelper(t, indent)
		local indentStr = string.rep(" ", indent)
		for k, v in pairs(t) do
			if type(v) == "table" then
				if type(k) == 'string' then
					print(indentStr .. '["'.. tostring(k)..'"]' .. " = {")
				else
					print(indentStr .. '['.. tostring(k)..']' .. " = {")
				end
				printTableHelper(v, indent + 2)
				print(indentStr .. "},")
			else
				if type(k) == 'string' then
					if type(v) == 'string' then
						print(indentStr .. '["'.. tostring(k)..'"]' .. " = " .. '"'.. tostring(v) ..'"'.. ",")

					else
						print(indentStr .. '["'.. tostring(k)..'"]' .. " = " .. tostring(v) .. ",")							
					end

					continue;
				end

				if type(v) == 'string' then
					print(indentStr .. '['.. tostring(k)..']' .. " = " ..'"'.. tostring(v) ..'"'.. ",")
				else
					print(indentStr .. '['.. tostring(k)..']' .. " = " .. tostring(v) .. ",")
				end
			end
		end
	end 

	print('\n\n\n')
	print("{")
	printTableHelper(tbl, 2)
	print("}")
end

function Utils.HTTPRequest(url: string, metodo: string, headers: any, cuerpo: any, OnlyBody: boolean)
	local NoBody = { 'GET', 'HEAD', 'DELETE', 'OPTIONS', 'TRACE' };
	Utils.MiAssert(url, 'No url provided');
	Utils.MiAssert(metodo, 'No method provided');

	if (table.find(NoBody, metodo) == nil) and (cuerpo == nil) then
		Utils.MiAssert(false, 'No body provided');
	end

	local Opciones = {
		Url = url,
		Method = metodo,
		Headers = headers or {}
	};

	if (cuerpo) then
		Opciones['Body'] = Http:JSONEncode(cuerpo);
	end;

	local succ, err = pcall(function()
		local res = fetch(Opciones);
		return res;
	end);

	if (succ == true and err['StatusCode'] == 200) then
		if (not err['Body']) or (err['Body'] == '') then
			if (OnlyBody == true) then
				warn('No body, return full response');
			end

			return Utils.GenerarStatus(true, err);
		end

		err['Body'] = Utils.CleanJSON(err['Body'])
		local Decode = Http:JSONDecode(err['Body'])
		return Utils.GenerarStatus(true, Decode);
	end;

	local String = 'Status Code: '..err['StatusCode']..'\n StatusMessage: '..err['StatusMessage']
	if (err['Body']) then
		String = String..'\n Body: '..err['Body']
	end

	return Utils.GenerarStatus(false, String);
end;

return Utils;
