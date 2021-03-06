local http = require "resty.http"

local ngx_log = ngx.log
local ngx_ERR = ngx.ERR
local ngx_INFO = ngx.INFO
local common_tab = {}
local config = ngx.shared.config

local function read_http(uri, uri1, args)
	--创建http客户端实例
	local httpc = http.new()

	local http_args = "?"
	for key, val in pairs(args) do
		http_args = http_args..key.."="..val.."&"
	end

	local resp, err = httpc:request_uri(uri, {
		method = "GET",
        path = uri1..http_args
	})

	if not resp then
		ngx.log(ngx.INFO, "\n" ,"request error :"..err)
		ngx.say("request error :", err)
		return
	end

	--获取状态码
	ngx.status = resp.status

	--获取响应头
	for k, v in pairs(resp.headers) do
		if k ~= "Transfer-Encoding" and k ~= "Connection" then
			ngx.header[k] = v
		end
	end

	--响应体
	common_tab["http_body"] = resp.body

	httpc:close()
end


--split string
local function lua_string_split(str, split_char)
	if str == nil or split_char == nil then
		return nil
	end
    local sub_str_tab = {};
    while (true) do
        local pos = string.find(str, split_char);
        if (not pos) then
            sub_str_tab[#sub_str_tab + 1] = str;
            break;
        end
        local sub_str = string.sub(str, 1, pos - 1);
        sub_str_tab[#sub_str_tab + 1] = sub_str;
        str = string.sub(str, pos + 1, #str);
    end

    return sub_str_tab;
end

--sub string
local function sub_utf8_string(s, n)
  local dropping = string.byte(s, n+1)
  if not dropping then return s end
  if dropping >= 128 and dropping < 192 then
    return sub_utf8_string(s, n-1)
  end
  return string.sub(s, 1, n)
end

-- share dict set
local function share_dict_set(k, v, expire)
	if k == nil or v == nil or config == nil then
		return false
	end
	if type(k) ~= "string" then
		return false
	end
	if expire ~= nil then 
		config:set(k, v, expire)
	else
		config:set(k, v)
	end	
	
end

-- share dict get
local function share_dict_get(k)
	if k == nil or config == nil then
		return false
	end
	if type(k) ~= "string" then
		return false
	end
	local value, flags = config:get(k)
	return value
end


local _M = {
    read_http = read_http,
	lua_string_split = lua_string_split,
	sub_utf8_string = sub_utf8_string,
	share_dict_set = share_dict_set,
	share_dict_get = share_dict_get,
	common_tab = common_tab
}

return _M