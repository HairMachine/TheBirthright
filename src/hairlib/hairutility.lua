local hairutility = {}

function hairutility.fileRead(file)
    local f = assert(io.open(file, "rb"))
    local content = f:read("*all")
    f:close()
    return content
end

return hairutility