local config = require "config"
local common = require "common"
local json = require "json"
local cjson = require "cjson"

local config_tab = config.config_tab

local ngx_log = ngx.log
local ngx_err = ngx.ERR
local ngx_info = ngx.INFO

local redirect_params = "&"
local request_method = ngx.req.get_method()

if "GET" == request_method then
    local args = ngx.req.get_uri_args()
    if type(args) == "table" then
	for key, val in pairs(args) do
		if key == "gclid"  then
		 	redirect_params = redirect_params..key.."="..val.."&"
		end
	end
end
elseif "POST" == request_method then
    ngx.req.read_body()
    local args, err = ngx.req.get_post_args()
    if not args then
	    ngx.say("failed to get post args: ", err)
	    return
	end
	for key, val in pairs(args) do
		if key == "gclid"  then
		 	redirect_params = redirect_params..key.."="..val.."&"
		end
	end
end

--get ip
local remote_ip =  ngx.var.remote_addr
if remote_ip == nil then
	remote_ip = ngx.req.get_headers()["X-Real-IP"]
end

ngx.log(ngx.INFO, "\n","remote_ip:"..remote_ip)

--get local by ip address
local ip_args = {
	format = "json",
	ip = remote_ip
}

local country

common.read_http(config_tab["ip_url"], "/iplookup/iplookup.php", ip_args)
local common_tab = common.common_tab
local ip_result = common_tab["http_body"]
ngx.log(ngx.INFO, "\n" ,"ip_result:"..ip_result)
if ip_result ~= nil then
	local data = cjson.decode(ip_result);
	if data ~= nil then
		country = data["country"]
	end
end

ngx.log(ngx.INFO, "\n" ,"country:"..country)

--redirect controller
if country ~= nil and country == "巴西" then
	--replace gclid param
	local final_redirect_params = string.gsub(redirect_params, "gclid", "aff_sub")
	local full_redirect_url = config_tab["aliexpress_extend_url"]..final_redirect_params
	ngx.log(ngx.INFO, "\n" ,"redirect_aliexpress_extend_url:"..full_redirect_url)
	ngx.redirect(full_redirect_url)
else
	ngx.log(ngx.INFO, "\n" ,"redirect_aliexpress_other_url:"..config_tab["aliexpress_other_url"])
	ngx.redirect(config_tab["aliexpress_other_url"])
end








