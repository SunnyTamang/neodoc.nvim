local parser = require("neodoc.parsers.python_parser")
local test = require("plenary.busted")

describe("Python Parser", function()
    it("should extract function name and parameters", function()
        local func_data = parser.extract_function()
        assert.is_not_nil(func_data)
        assert.is_not_nil(func_data.name)
        assert.is_not_nil(func_data.params)
    end)
end)
