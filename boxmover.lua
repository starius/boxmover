#!/usr/bin/env lua

-- game:

-- #########
-- #   - - #
-- # #o  o #
-- #    i  #
-- #########

-- i + - = I
-- o + - = 0

function BoxMover(str)
    local height, width
    do
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

    function canMove(game, man2_row, man2_col, move_boxes)
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
        if not move_boxes then
            if isFree(game[man2_row][man2_col]) then
                return true
            end
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
        return false
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

    function tryMove(new_states, str, man2_row, man2_col, move_boxes)
        local game = strToGame(str)
        if canMove(game, man2_row, man2_col, move_boxes) then
            moveMan(game, man2_row, man2_col)
            table.insert(new_states, gameToStr(game))
        end
    end

    function allMoves(str, move_boxes)
        local new_states = {}
        local game = strToGame(str)
        local man_row, man_col = findMan(game)
        tryMove(new_states, str, man_row - 1, man_col, move_boxes)
        tryMove(new_states, str, man_row + 1, man_col, move_boxes)
        tryMove(new_states, str, man_row, man_col - 1, move_boxes)
        tryMove(new_states, str, man_row, man_col + 1, move_boxes)
        return new_states
    end

    function isEnd(str)
        return str:find('[-I]') == nil
    end

    function printMoves(parent, end_state)
        local states = {}
        local state = end_state
        while state ~= 'init' do
            table.insert(states, 1, state)
            state = parent[state]
        end
        -- remove moves after end
        while states[#states - 1] and isEnd(states[#states - 1]) do
            table.remove(states, #states)
        end
        for _, state in ipairs(states) do
            print(state)
        end
    end

    function clone_states(states)
        local states_copy = {}
        for k, v in pairs(states) do
            states_copy[k] = v
        end
        return states_copy
    end

    function discoverNoBoxMoves(new_states, parent)
        -- try all moves which do not move boxes (multi-move)
        local new_states2 = clone_states(new_states)
        while not isEmpty(new_states2) do
            local state = next(new_states2)
            new_states2[state] = nil
            local next_states = allMoves(state, false)
            for _, next_state in pairs(next_states) do
                if parent[next_state] == nil then
                    parent[next_state] = state
                    new_states[next_state] = 1
                    new_states2[next_state] = 1
                end
            end
        end
        return new_states
    end

    function discoverBoxMoves(new_states, parent)
        -- try all moves which do move boxes (single-move)
        local new_states2 = {}
        for state, _ in pairs(new_states) do
            local next_states = allMoves(state, true)
            for _, next_state in pairs(next_states) do
                if parent[next_state] == nil then
                    parent[next_state] = state
                    new_states2[next_state] = 1
                end
            end
        end
        return new_states2
    end

    function solveGame(str)
        do
            local game = strToGame(str)
            height = #game
            width = #game[1]
        end
        local parent = {[str] = 'init'}
        local new_states = {[str] = 1}
        while not isEmpty(new_states) do
            new_states = discoverNoBoxMoves(new_states, parent)
            new_states = discoverBoxMoves(new_states, parent)
            for state, _ in pairs(new_states) do
                if isEnd(state) then
                    print('solved!')
                    printMoves(parent, state)
                    return
                end
            end
        end
    end

    solveGame(str)
end

if arg and arg[1] then
    local fname = arg[1]
    local f = io.open(fname)
    local str = f:read("*a")
    f:close()
    BoxMover(str)
else
BoxMover([[
#########
#   - - #
# #o  o #
#    i  #
#########
]]
)
end

