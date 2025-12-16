local schema = require("lapis.db.schema")
local types = schema.types



return {
    [1] = function()
    schema.create_table("user_ids", {
        { "id", types.id },
        { "username", types.varchar },
        { "user_id", types.varchar },
        "PRIMARY KEY (username)"
    })
    end
}





