local function check_nested_field(tbl, ...)
    local current = tbl
    for _, key in ipairs({...}) do
        if type(current) ~= "table" then
            return nil 
        end
        current = current[key]
    end
    return current 
end

return { check_nested_field = check_nested_field }