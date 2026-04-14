local M = {}

-- Default options
local config = {
	symbol = "┆",
	column = nil, -- Optional hard-code column(s). e.g., 80, "80,120", or {80, 120}
}

--- Sets up a hardware-optimized virtual vertical guide at a fixed column
--- @param opts table? Options for the virtual column
function M.setup(opts)
	opts = opts or {}
	local symbol = opts.symbol or config.symbol
	local custom_col = opts.column or config.column

	local ns = vim.api.nvim_create_namespace("custom_virt_column")

	vim.api.nvim_set_decoration_provider(ns, {
		on_win = function(_, winid, bufnr, toprow, botrow)
			-- Determine target columns
			local cols = {}
			if type(custom_col) == "table" then
				cols = custom_col
			elseif type(custom_col) == "number" then
				cols = { custom_col }
			elseif type(custom_col) == "string" and custom_col ~= "" then
				for s in string.gmatch(custom_col, "([^,]+)") do
					local c = tonumber(s)
					if c then table.insert(cols, c) end
				end
			else
				local col_setting = vim.wo[winid].colorcolumn
				if col_setting and col_setting ~= "" then
					for s in string.gmatch(col_setting, "([^,]+)") do
						local c = tonumber(s)
						if c then table.insert(cols, c) end
					end
				else
					cols = { 80 }
				end
			end

			if #cols == 0 then
				return false
			end

			-- Only apply to normal buffers
			local bt = vim.bo[bufnr].buftype
			if bt ~= "" and bt ~= "acwrite" then
				return false
			end

			local wininfo = vim.fn.getwininfo(winid)[1]
			local offset = wininfo and wininfo.textoff or 0

			-- Use nvim_win_call to safely execute foldclosed in the window's context
			vim.api.nvim_win_call(winid, function()
				local lines = vim.api.nvim_buf_get_lines(bufnr, toprow, botrow + 1, false)
				for i, line in ipairs(lines) do
					local lnum = toprow + i

					-- Skip folded lines contextually for this window
					if vim.fn.foldclosed(lnum) == -1 then
						local line_width = vim.fn.strdisplaywidth(line)
						
						-- Draw for each column requested
						for _, col in ipairs(cols) do
							if line_width < col then
								local target_col = col + offset - 1
								-- ephemeral=true injects the mark directly into the redraw cycle!
								vim.api.nvim_buf_set_extmark(bufnr, ns, lnum - 1, 0, {
									virt_text = { { symbol, "Comment" } },
									virt_text_win_col = target_col,
									priority = 10,
									ephemeral = true,
								})
							end
						end
					end
				end
			end)
		end,
	})
end

return M
