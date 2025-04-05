local template = require("neodoc.templates.google")
local test = require("plenary.busted")

describe("Google Template", function()
    it("should generate a valid docstring", function()
        local func_data = { name = "my_function", params = "x, y" }
        local docstring = template.generate(func_data)
        assert.is_true(docstring:match("Args:"))
    end)
end)
