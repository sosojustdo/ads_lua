
local args = ngx.req.get_uri_args();
for k,v in pairs(args) do
    ngx.say("key:", k, " value:", v);
end
