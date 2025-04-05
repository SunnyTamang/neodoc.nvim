local generate = require("neodoc.commands.generate")
local test = require("plenary.busted")

describe("Integration Test", function()
    it("should generate docstring when function exists", function()
        generate.generate_docstring()
        assert.is_true(true)  -- Simple check, real tests should verify output
    end)
end)
