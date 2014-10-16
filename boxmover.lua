#!/usr/bin/env lua

-- game:

-- #########
-- #   - - #
-- # #o  o #
-- #    i  #
-- #########

-- i + - = I
-- o + - = 0

function sizes(game)
    local height = #game
    local width = #game[1]
    return height, width
end

function isEmpty(t)
    return next(t) == nil
end

function isMan(char)
    return char == 'i' or char == 'I'
end

function isBomb(char)
    return char == '-' or char == 'I' or char == '0'
end

function isBox(char)
    return char == 'o' or char == '0'
end

function isFree(char)
    return char == ' ' or char == '-'
end

function gameToStr(game)
    local height, width = sizes(game)
    local rows = {}
    for row = 1, height do
        table.insert(rows, table.concat(game[row]) .. '\n')
    end
    return table.concat(rows)
end

function strToGame(str)
    local game = {}
    table.insert(game, {})
    local row = game[#game]
    for i = 1, #str do
        local c = str:sub(i, i)
        if c == '\n' then
            if not isEmpty(row) then
                table.insert(game, {})
                row = game[#game]
            end
        else
            table.insert(row, c)
        end
    end
    if isEmpty(game[#game]) then
        game[#game] = nil
    end
    return game
end

function findMan(game)
    local height, width = sizes(game)
    for row = 1, height do
        for col = 1, width do
            if isMan(game[row][col]) then
                return row, col
            end
        end
    end
    print(gameToStr(game))
    assert(false)
end

function cellIsStandable(game, row, col)
    local height, width = sizes(game)
    if row > height or row < 1 then
        return false
    end
    if col > width or col < 1 then
        return false
    end
    if game[row][col] == '#' then
        return false
    end
    return true
end

function canMove(game, man2_row, man2_col)
    if not cellIsStandable(game, man2_row, man2_col) then
        return false
    end
    local man_row, man_col = findMan(game)
    local row_diff = man2_row - man_row
    local col_diff = man2_col - man_col
    if row_diff ~= 0 and col_diff ~= 0 then
        return false
    end
    if math.abs(row_diff) > 1 or math.abs(col_diff) > 1 then
        return false
    end
    if isFree(game[man2_row][man2_col]) then
        return true
    else
        local man3_row = man2_row + row_diff
        local man3_col = man2_col + col_diff
        if not cellIsStandable(game, man3_row, man3_col) then
            return false
        end
        if isBox(game[man3_row][man3_col]) then
            return false
        end
        return true
    end
end

function moveMan(game, man2_row, man2_col)
    local man_row, man_col = findMan(game)
    if game[man_row][man_col] == 'i' then
        game[man_row][man_col] = ' '
    end
    if game[man_row][man_col] == 'I' then
        game[man_row][man_col] = '-'
    end
    if game[man2_row][man2_col] == ' ' then
        game[man2_row][man2_col] = 'i'
    end
    if game[man2_row][man2_col] == '-' then
        game[man2_row][man2_col] = 'I'
    end
    if isBox(game[man2_row][man2_col]) then
        if game[man2_row][man2_col] == 'o' then
            game[man2_row][man2_col] = 'i'
        end
        if game[man2_row][man2_col] == '0' then
            game[man2_row][man2_col] = 'I'
        end
        local row_diff = man2_row - man_row
        local col_diff = man2_col - man_col
        local man3_row = man2_row + row_diff
        local man3_col = man2_col + col_diff
        if game[man3_row][man3_col] == ' ' then
            game[man3_row][man3_col] = 'o'
        end
        if game[man3_row][man3_col] == '-' then
            game[man3_row][man3_col] = '0'
        end
    end
end

function tryMove(new_states, str, man2_row, man2_col)
    local game = strToGame(str)
    if canMove(game, man2_row, man2_col) then
        moveMan(game, man2_row, man2_col)
        table.insert(new_states, gameToStr(game))
    end
end

function allMoves(str)
    local new_states = {}
    local game = strToGame(str)
    local man_row, man_col = findMan(game)
    tryMove(new_states, str, man_row - 1, man_col)
    tryMove(new_states, str, man_row + 1, man_col)
    tryMove(new_states, str, man_row, man_col - 1)
    tryMove(new_states, str, man_row, man_col + 1)
    return new_states
end

function isEnd(str)
    return str:find('o') == nil
end

function printMoves(parent, end_state)
    local states = {}
    local state = end_state
    while state ~= 'init' do
        table.insert(states, 1, state)
        state = parent[state]
    end
    for _, state in ipairs(states) do
        print(state)
    end
end

function solveGame(str)
    local parent = {[str] = 'init'}
    local new_states = {[str] = 1}
    while not isEmpty(new_states) do
        local state = next(new_states)
        new_states[state] = nil
        local next_states = allMoves(state)
        for _, next_state in pairs(next_states) do
            if parent[next_state] == nil then
                parent[next_state] = state
                new_states[next_state] = 1
                if isEnd(next_state) then
                    print('solved!')
                    printMoves(parent, next_state)
                    return
                end
            end
        end
    end
end

if arg and arg[1] then
    local fname = arg[1]
    local f = io.open(fname)
    local str = f:read("*a")
    f:close()
    solveGame(str)
else
solveGame([[
#########
#   - - #
# #o  o #
#    i  #
#########
]]
)
end

