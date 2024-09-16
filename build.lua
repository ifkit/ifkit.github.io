-- https://pandoc.org/MANUAL.html#variables
-- https://pandoc.org/lua-filters.html
-- https://github.com/pandoc/lua-filters

local function dump(o)
	if type(o) == 'table' then
		local s = '{ '
		for k, v in pairs(o) do
			if type(k) ~= 'number' then k = '"' .. k .. '"' end
			s = s .. '[' .. k .. '] = ' .. dump(v) .. ','
		end
		return s .. '} '
	end
	return tostring(o)
end

local function prnt(o)
	io.stderr:write("@@@ " .. dump(o) .. "\n")
end

local function innerText(h)
	local text = ""
	h.content:walk({
		Str = function(e)
			text = text .. " " .. e.text
		end
	})
	return h, pandoc.text.sub(text, 2, pandoc.text.len(text))
end

function Link(el)
	if not string.match(el.target, "^%a+://") then
		el.target = string.gsub(el.target, "%.md$", ".html")
		el.target = string.gsub(el.target, "%.md#", ".html#")
	end
	if string.match(el.target, "^%a+://") then
		el.attributes.target = "_blank"
	end
	return el
end

function Pandoc(doc)
	local meta = doc.meta
	local blocks = {}
	for _, el in pairs(doc.blocks) do
		if el.t == 'Header' then
			local el, text = innerText(el)
			if el.level == 1 and text ~= "" then
				meta.title = text
			end
		end
		table.insert(blocks, el)
	end
	return pandoc.Pandoc(blocks, meta)
end
