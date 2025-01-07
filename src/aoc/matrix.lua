local function identity(a)
	return a
end

local Cell = {}
Cell.__index = Cell

function Cell.new(row, col, value)
	return setmetatable({
		row = row,
		col = col,
		value = value,
	}, Cell)
end

function Cell.__eq(this, other)
	return this.row == other.row and this.col == other.col
end

function Cell.__tostring(this)
	return string.format("%s:%s", this.row, this.col)
end

local Matrix = {
	N = { row = -1, col = 0 },
	NE = { row = -1, col = 1 },
	E = { row = 0, col = 1 },
	SE = { row = 1, col = 1 },
	S = { row = 1, col = 0 },
	SW = { row = 1, col = -1 },
	W = { row = 0, col = -1 },
	NW = { row = -1, col = -1 },
}
Matrix.__index = Matrix

function Matrix.Cell(row, col, value)
	return Cell.new(row, col, value)
end

function Matrix.fromFile(filepath, mapFn)
	mapFn = mapFn or identity
	local matrix = {}
	for line in io.lines(filepath) do
		local row = {}
		for cell in line:gmatch(".") do
			table.insert(row, Matrix.Cell(#matrix + 1, #row + 1, mapFn(cell)))
		end
		table.insert(matrix, row)
	end
	return Matrix.new(matrix)
end

function Matrix.fill(size, value)
	local m = {}
	for _ = 1, size do
		local row = {}
		for _ = 1, size do
			table.insert(row, Matrix.Cell(#m + 1, #row + 1, value))
		end
		table.insert(m, row)
	end
	return Matrix.new(m)
end

function Matrix.new(matrix)
	return setmetatable({ _m = matrix }, Matrix)
end

function Matrix:contains(row, col)
	if row < 1 or row > #self._m then
		return false
	end

	if col < 1 or col > #self._m[row] then
		return false
	end

	return true
end

function Matrix:find(value)
	for _, cell in pairs(self) do
		if cell.value == value then
			return cell
		end
	end
end

function Matrix:get(row, col)
	if self:contains(row, col) then
		return self._m[row][col]
	end
end

function Matrix:next(from, dir)
	local nRow = from.row + dir.row
	local nCol = from.col + dir.col
	if self:contains(nRow, nCol) then
		return self._m[nRow][nCol]
	end
end

function Matrix:prev(from, dir)
	local pRow = from.row - dir.row
	local pCol = from.col - dir.col
	if self:contains(pRow, pCol) then
		return self._m[pRow][pCol]
	end
end

function Matrix:put(row, col, value)
	if value ~= nil and self:contains(row, col) then
		self._m[row][col].value = value
	end
end

function Matrix:rows()
	return pairs(self._m)
end

function Matrix:__pairs()
	local row, col = 1, 1
	local index = 0
	return function()
		if row > #self._m then
			return
		end

		if col > #self._m[row] then
			if row == #self._m then
				return nil
			end
			row = row + 1
			col = 1
		end

		index = index + 1
		local value = self._m[row][col]
		col = col + 1
		return index, value
	end,
		self,
		nil
end

return Matrix
