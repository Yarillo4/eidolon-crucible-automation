_G.Time = {}
_G.Crypto = {}
_G.Debug = {
	levels = {
		[1] = "[FATAL] ",
		[2] = "[error] ",
		[3] = "[warning] ",
		[4] = "[info] ",
		[5] = "[debug] ",
		[6] = "",
		[7] = "",
		[8] = "",
		[9] = "",
	},
	colors = {
		[1] = {colors.black,  colors.red},
		[2] = {colors.red,    nil},
		[3] = {colors.orange, nil},
		[4] = {colors.yellow, nil},
		[5] = {colors.lightBlue,  nil},
		[6] = {colors.white,  nil},
		[7] = {colors.white,  nil},
		[8] = {colors.white,  nil},
		[9] = {colors.white,  nil},
	}
}

function Debug.log(str, n, level)
	local old_bg
	if Debug.colors[level] and Debug.colors[level][2] then
		old_bg = term.getBackgroundColor()
		term.setBackgroundColor(Debug.colors[level][2])
	end

    if n ~= nil then 
        term.setCursorPos(1, n)
        term.clearLine()
    end

    local old_ctxt = term.getBackgroundColor()
    term.setTextColor(Debug.colors[level][1])
    term.write("[" .. os.clock() .. "]" .. Debug.levels[level])
    print(str)
    term.setTextColor(old_ctxt)

    if old_bg then
    	term.setBackgroundColor(old_bg)
    end
end

function Debug.fatal(str, n)
	return Debug.log(str, n, 1)
end
function Debug.fatalf(format, str, ...)
	return Debug.fatal(string.format(format, str, ...))
end

function Debug.error(str, n)
	return Debug.log(str, n, 2)
end
function Debug.errorf(format, str, ...)
	return Debug.error(string.format(format, str, ...))
end
function Debug.warning(str, n)
	return Debug.log(str, n, 3)
end
Debug.warn = Debug.warning
function Debug.warningf(format, str, ...)
	return Debug.warning(string.format(format, str, ...))
end
function Debug.info(str, n)
	return Debug.log(str, n, 4)
end
function Debug.infof(format, str, ...)
	return Debug.info(string.format(format, str, ...))
end
function Debug.debug(str, n)
	return Debug.log(str, n, 5)
end
function Debug.debugf(format, str, ...)
	return Debug.debug(string.format(format, str, ...))
end




function printf(format, ...)
    return print(string.format(format, ...))
end

function Time.timestamp()
	local timestamp = nil
	local start_time = os.clock()
	local r = http.get("http://www.google.com")
	if r then
		local h = r.getResponseHeaders()
		if h then
			local debug_time = string.sub(h.Date, 18, 19) .. string.sub(h.Date, 21, 22) .. string.sub(h.Date, 24, 25)
			timestamp = 0
			local h_in_s = tonumber(string.sub(h.Date, 18, 19))*3600
			if h_in_s == nil then return end
			local m_in_s = tonumber(string.sub(h.Date, 21, 22))*60
			if m_in_s == nil then return end
			local s_in_s = tonumber(string.sub(h.Date, 24, 25))
			if s_in_s == nil then return end
			timestamp = timestamp + h_in_s
			timestamp = timestamp + m_in_s
			timestamp = timestamp + s_in_s
			timestamp = timestamp - (os.clock()-start_time)

			return timestamp
		end
	end
end

local function crc32()
	--[[
	This function is taken from github.com/SafeteeWoW 
	It has been modified slightly
	
	
	Copyright (C) 2022 SafeteeWoW github.com/SafeteeWoW

	This software is provided 'as-is', without any express or implied
	warranty.  In no event will the authors be held liable for any damages
	arising from the use of this software.

	Permission is granted to anyone to use this software for any purpose,
	including commercial applications, and to alter it and redistribute it
	freely, subject to the following restrictions:

	1. The origin of this software must not be misrepresented; you must not
	   claim that you wrote the original software. If you use this software
	   in a product, an acknowledgment in the product documentation would be
	   appreciated but is not required.
	2. Altered source versions must be plainly marked as such, and must not be
	   misrepresented as being the original software.
	3. This notice may not be removed or altered from any source distribution.
	--]]

	local string_byte = string.byte

	-- Calculate xor for two unsigned 8bit numbers (0 <= a,b <= 255)
	local function Xor8(a, b)
		local ret = 0
		local fact = 128
		while fact > a and fact > b do
			fact = fact / 2
		end
		while fact >= 1 do
	        ret = ret + (((a >= fact or b >= fact)
				and (a < fact or b < fact)) and fact or 0)
	        a = a - ((a >= fact) and fact or 0)
	        b = b - ((b >= fact) and fact or 0)
		    fact = fact / 2
		end
		return ret
	end

	-- table to cache the result of uint8 xor(x, y)  (0<=x,y<=255)
	local _xor8_table

	local function GenerateXorTable()
		assert(not _xor8_table)
		_xor8_table = {}
		for i = 0, 255 do
			local t = {}
			_xor8_table[i] = t
			for j = 0, 255 do
				t[j] = Xor8(i, j)
			end
		end
	end

	local _crc_table0 = {
		[0]=0,150,44,186,25,143,53,163,50,164,30,136,43,189,7,145,100,242,72,222,
		125,235,81,199,86,192,122,236,79,217,99,245,200,94,228,114,209,71,253,107,
		250,108,214,64,227,117,207,89,172,58,128,22,181,35,153,15,158,8,178,36,135,
		17,171,61,144,6,188,42,137,31,165,51,162,52,142,24,187,45,151,1,244,98,216,
		78,237,123,193,87,198,80,234,124,223,73,243,101,88,206,116,226,65,215,109,
		251,106,252,70,208,115,229,95,201,60,170,16,134,37,179,9,159,14,152,34,180,
		23,129,59,173,32,182,12,154,57,175,21,131,18,132,62,168,11,157,39,177,68,
		210,104,254,93,203,113,231,118,224,90,204,111,249,67,213,232,126,196,82,241,
		103,221,75,218,76,246,96,195,85,239,121,140,26,160,54,149,3,185,47,190,
		40,146,4,167,49,139,29,176,38,156,10,169,63,133,19,130,20,174,56,155,13,183,
		33,212,66,248,110,205,91,225,119,230,112,202,92,255,105,211,69,120,238,84,
		194,97,247,77,219,74,220,102,240,83,197,127,233,28,138,48,166,5,147,41,191,
		46,184,2,148,55,161,27,141}
	local _crc_table1 = {
		[0]=0,48,97,81,196,244,165,149,136,184,233,217,76,124,45,29,16,32,113,65,
		212,228,181,133,152,168,249,201,92,108,61,13,32,16,65,113,228,212,133,181,
		168,152,201,249,108,92,13,61,48,0,81,97,244,196,149,165,184,136,217,233,124,
		76,29,45,65,113,32,16,133,181,228,212,201,249,168,152,13,61,108,92,81,97,48,
		0,149,165,244,196,217,233,184,136,29,45,124,76,97,81,0,48,165,149,196,244,
		233,217,136,184,45,29,76,124,113,65,16,32,181,133,212,228,249,201,152,168,
		61,13,92,108,131,179,226,210,71,119,38,22,11,59,106,90,207,255,174,158,147,
		163,242,194,87,103,54,6,27,43,122,74,223,239,190,142,163,147,194,242,103,87,
		6,54,43,27,74,122,239,223,142,190,179,131,210,226,119,71,22,38,59,11,90,106,
		255,207,158,174,194,242,163,147,6,54,103,87,74,122,43,27,142,190,239,223,
		210,226,179,131,22,38,119,71,90,106,59,11,158,174,255,207,226,210,131,179,
		38,22,71,119,106,90,11,59,174,158,207,255,242,194,147,163,54,6,87,103,122,
		74,27,43,190,142,223,239}
	local _crc_table2 = {
		[0]=0,7,14,9,109,106,99,100,219,220,213,210,182,177,184,191,183,176,185,190,
		218,221,212,211,108,107,98,101,1,6,15,8,110,105,96,103,3,4,13,10,181,178,
		187,188,216,223,214,209,217,222,215,208,180,179,186,189,2,5,12,11,111,104,
		97,102,220,219,210,213,177,182,191,184,7,0,9,14,106,109,100,99,107,108,101,
		98,6,1,8,15,176,183,190,185,221,218,211,212,178,181,188,187,223,216,209,214,
		105,110,103,96,4,3,10,13,5,2,11,12,104,111,102,97,222,217,208,215,179,180,
		189,186,184,191,182,177,213,210,219,220,99,100,109,106,14,9,0,7,15,8,1,6,98,
		101,108,107,212,211,218,221,185,190,183,176,214,209,216,223,187,188,181,178,
		13,10,3,4,96,103,110,105,97,102,111,104,12,11,2,5,186,189,180,179,215,208,
		217,222,100,99,106,109,9,14,7,0,191,184,177,182,210,213,220,219,211,212,221,
		218,190,185,176,183,8,15,6,1,101,98,107,108,10,13,4,3,103,96,105,110,209,
		214,223,216,188,187,178,181,189,186,179,180,208,215,222,217,102,97,104,111,
		11,12,5,2}
	local _crc_table3 = {
		[0]=0,119,238,153,7,112,233,158,14,121,224,151,9,126,231,144,29,106,243,132,
		26,109,244,131,19,100,253,138,20,99,250,141,59,76,213,162,60,75,210,165,53,
		66,219,172,50,69,220,171,38,81,200,191,33,86,207,184,40,95,198,177,47,88,
		193,182,118,1,152,239,113,6,159,232,120,15,150,225,127,8,145,230,107,28,133,
		242,108,27,130,245,101,18,139,252,98,21,140,251,77,58,163,212,74,61,164,211,
		67,52,173,218,68,51,170,221,80,39,190,201,87,32,185,206,94,41,176,199,89,46,
		183,192,237,154,3,116,234,157,4,115,227,148,13,122,228,147,10,125,240,135,
		30,105,247,128,25,110,254,137,16,103,249,142,23,96,214,161,56,79,209,166,63,
		72,216,175,54,65,223,168,49,70,203,188,37,82,204,187,34,85,197,178,43,92,
		194,181,44,91,155,236,117,2,156,235,114,5,149,226,123,12,146,229,124,11,134,
		241,104,31,129,246,111,24,136,255,102,17,143,248,97,22,160,215,78,57,167,
		208,73,62,174,217,64,55,169,222,71,48,189,202,83,36,186,205,84,35,179,196,
		93,42,180,195,90,45}

	--- Calculate the CRC-32 checksum of the string.
	-- @param str [string] the input string to calculate its CRC-32 checksum.
	-- @param init_value [nil/integer] The initial crc32 value. If nil, use 0
	-- @return [integer] The CRC-32 checksum, which is greater or equal to 0,
	-- and less than 2^32 (4294967296).
	local function crc32(str, init_value)
		-- TODO: Check argument
		local crc = (init_value or 0) % 4294967296
		if not _xor8_table then
			GenerateXorTable()
		end
	    -- The value of bytes of crc32
		-- crc0 is the least significant byte
		-- crc3 is the most significant byte
	    local crc0 = crc % 256
	    crc = (crc - crc0) / 256
	    local crc1 = crc % 256
	    crc = (crc - crc1) / 256
	    local crc2 = crc % 256
	    local crc3 = (crc - crc2) / 256

		local _xor_vs_255 = _xor8_table[255]
		crc0 = _xor_vs_255[crc0]
		crc1 = _xor_vs_255[crc1]
		crc2 = _xor_vs_255[crc2]
		crc3 = _xor_vs_255[crc3]
	    for i=1, #str do
			local byte = string_byte(str, i)
			local k = _xor8_table[crc0][byte]
			crc0 = _xor8_table[_crc_table0[k] ][crc1]
			crc1 = _xor8_table[_crc_table1[k] ][crc2]
			crc2 = _xor8_table[_crc_table2[k] ][crc3]
			crc3 = _crc_table3[k]
	    end
		crc0 = _xor_vs_255[crc0]
		crc1 = _xor_vs_255[crc1]
		crc2 = _xor_vs_255[crc2]
		crc3 = _xor_vs_255[crc3]
	    crc = crc0 + crc1*256 + crc2*65536 + crc3*16777216
	    return crc
	end

	Crypto.crc32 = crc32
end
crc32()

return {Debug, Crypto, Time}
