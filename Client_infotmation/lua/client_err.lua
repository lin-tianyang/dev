--============================================================================
-- Description:根据post信息,生成对应信息,并按天分类
-- date: 2020-08-08
-- Emain: lintianyang@kurogame.com
-- Explanation：结合openresty content_by_lua_file conf/lua/playerlog.lua
--============================================================================
--local function unicode_to_utf8(convertStr)
local cjson = require "cjson"
-- 内容输出到文本
function writeFile(fileName,content)
    local f = assert(io.open(fileName,'a'))
    f:write(content)
    f:close()
end


--[[
记录头部信息做调试的时候使用
fucntion head_info()
    for k,v in pairs(headers) do
        if type(v) == "table" then
            ngx.say(k, " : ", table.concat(v, ","), "<br/>")
        else
            writeFile("/var/log/openresty/clienterr_headers.log", k.. " : ".. v.. "<br/>")
            writeFile("/var/log/openresty/clienterr_headers.log", "\n")
            ngx.say(k, " : ", v, "<br/>")
        end
    end
end
]]




-- 读取内容必须先执行的命令
ngx.req.read_body()

--local date = ngx.req.read_body()


-- 如果body为空就直接丢弃,节约效率。
data = ngx.req.get_body_data()

if  data ~= nil then

    --规定的校验值
    token      = "kuroclient"
    -- body信息太多了,在头部信息做效验
    headers = ngx.req.get_headers()

    clienttime =  headers["time"]
    -- 头部信息中有下划线会报错device_id,改成device
    device_id  =  headers["device"]
    sign       =  headers["sign"]
    identifier =  headers["identifier"]
    version    =  headers["version"]
    platform   =  headers["platform"]

    --  按天分目录,需要注意目录权限
    nowtime = os.date("%Y%m%d",unixtime)
    --nowtime = ngx.localtime()
    client_log = '/home/log/client_log/'..nowtime..'/'

    -- 网上说的直接mkdir会报错," "需要多拼接一个空格
    os.execute("mkdir -p".." "..client_log)
    -- md5值校验
    playmd5 = ngx.md5(token..clienttime)

    --lua脚本中字符串拼接用 .. 实现
    clientname = client_log..platform..'_'..identifier..'_'..version..'.log'
    clientdiff = '/var/log/openresty/difftypes.log'
    clientsame = '/var/log/openresty/same.log'
    --ngx.say(headers["tt"])

    --判断signmd5值
    --if sign  == playmd5 then
            --ngx.say(headers["device_id"])
            --ngx.say(headers["time"])
            --ngx.say(headers["sign"])

            --ngx.say(filename)
            --writeFile(clientname, data)
            --writeFile(clientname, "\n")
        local arg = ngx.req.get_post_args()

        for k, v in pairs(arg) do
            if type(v) == "table" then
                local obj = cjson.decode(v)
                ngx.say(obj.log:sub(1,100))
            else
               local obj = cjson.decode(v)
               --检查log字段长度
               --kurolog_len = #obj.log
               --截取部分字段转化为字母
               sublog = obj.log:sub(1,200)
               str1 = string.gsub(sublog, "%p", "9")
               str2 = string.gsub(str1, "%d", "m")
               --读取log类型
               local diff_file = io.open(clientdiff)
               local readall = diff_file:read("*a")
               
               diff_str = string.match(readall,kurolog_sub)
               --如果匹配不到,就将信息写入文件,反之则抛弃log 
               if diff_str == nil then
               --local readall = file:read("*a")
               --pow=string.match(readall,kurolog_sub)
                 
                 writeFile(clientname, k.. ":" ..v..'\n')
                 writeFile(clientdiff,str2)   
               else
                 writeFile(clientsame,"device_id"..":"..device_id.."version"..":"..version.."log"..":"str2..'\n')


               -- 记录文件
               --local file = io.open("/var/log/openresty/err_info.log")
               --local readall = file:read("*a")
               --pow=string.match(readall,kurolog_sub)
               --if pow == nil then
               --     writeFile("/var/log/openresty/err_info.log",kurolog_sub)
               --     writeFile(clientname, '\n')
               --     writeFile(clientname, k.. ":" ..v..'\n')
               --    writeFile(clientname, '\n')
               --else
               --     writeFile("/var/log/openresty/log_info.log",kurolog_sub..'\n')
               --end
            end
        end

    --else
            -- 要不要记录错误信息到文本?
            --writeFile("/var/log/test.log", "this is error sign")
            --writeFile("/var/log/test.log", playmd5)
    --end


else
    writeFile("/var/log/openresty/clienterr_body.log")

end