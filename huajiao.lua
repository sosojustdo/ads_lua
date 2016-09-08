local config = require "config"
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

--replace gclid param
local final_redirect_params = string.gsub(redirect_params, "gclid", "aff_sub")

--ngx.log(ngx.INFO, "\n","redirect_params_is:"..final_redirect_params)

local full_redirect_url = config_tab["huajia_redirect_url"]..final_redirect_params

ngx.log(ngx.INFO, "\n" ,"full_redirect_url:"..full_redirect_url)

ngx.redirect(full_redirect_url)




