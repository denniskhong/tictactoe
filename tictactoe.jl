#!/usr/bin/env julia

# Tic Tac Toe
# Author: Dennis W. K. Khong <denniswkkhong@gmail.com>
# Github: https://github.com/denniskhong/tictactoe
# Date: 2023-05-06
# License: GPL 3.0

const Max_board_size = 9
# This program is not designed to support a Max_board_size of larger than 26 because
# of the limitation of using the alphabets as row labels. It can be improved by using
# double characters, but it'll be pointless in actual game play.

# Define input function
function input(prompt, validate=nothing, errmessage="Invalid response.")
    """
    Function input(prompt, [validate], [errmessage="Invalid response."])
    Implements the input function by:
    (1) Validating the response in a validate vector,
    (2) Returning response in the same type as the element of validate
    vector,
    (3) If no value for validate is provided, then no validating is made,
    (4) Providing a default error message.
    """

    loop = true
    if validate == nothing
        print(prompt)
        return readline()
    else
        while loop
            print(prompt)
            response = readline()
            if uppercase(response) in uppercase.(string.(validate))
                loop = false
                response_parsed = tryparse(Int64, response)
                if !isnothing(response_parsed)
                    return response_parsed
                else
                    response_parsed = tryparse(Float64, response)
                    if !isnothing(response_parsed)
                        return response_parsed
                    else
                        return response
                    end
                end
            else
                println(errmessage)
            end
        end
    end
end


# Convert moves to row and col
function  move2rowcol(move)
    # Only accepts a single character row label.
    return (Int(move[1])-64), tryparse(Int64, move[2:length(move)])
end


# Convert row and col to move
function rowcol2move(row, col)
    return row_labels[row] * col_labels[col]
end


# Register a move
function register_move(move)
    global board, current_player, moves
    
    row, col = move2rowcol(move)
    board[row, col] = current_player
    moves = filter(s -> s != move, moves)
end


# Display board
function display_board()
    global board, row_labels, col_labels, board_size

    last_r = board_size * 2 + 2
    last_c = board_size + 1
    for r in 0:last_r
        for c in 0:last_c
            if r == 0 && c == 0
                print("┌───")
            elseif r == 0 && c == last_c
                println("┐")
            elseif r == 0
                print("┬───")
            elseif r == last_r && c == 0
                print("└───")
            elseif r == last_r && c == last_c
                println("┘")
            elseif r == last_r
                print("┴───")
            elseif isodd(r) && c == last_c # Odd number row
                println("│")
            elseif isodd(r)
                if r == 1 && c == 0
                    print("│   ")
                elseif r == 1 && c > 0
                    print("│ $(col_labels[c]) ")
                elseif r > 1 && c == 0
                    print("│ $(row_labels[Int((r-1)/2)]) ")
                else  # r > 1 && col > 0
                    print("│ $(board[Int((r-1)/2), c]) ")
                end
            elseif iseven(r) && c == 0 # Even number row
                print("├───")
            elseif iseven(r) && c == last_c
                println("┤")
            elseif iseven(r)
                print("┼───")
            end
        end
    end
    println() # Print line break
end


# Exclude spaces
function exclude_spaces(vec)
    return filter(s -> !(s in [" ", " "]), vec)
end


# Get number of unique items excluding spaces
function num_unique(vec)
    return length(unique(vec))
end


# Check for a win
function check_win()
    global board_size, consecutive

    # Check by row and col
    for m in 1:board_size
        for n in 1:board_size-consecutive+1
            # create row vector
            vec = exclude_spaces(board[m, n:n+consecutive-1])
            if (length(vec) == consecutive) && (num_unique(vec) == 1)
                return true
            end

            # create col vector
            vec = exclude_spaces(board[n:n+consecutive-1, m])
            if (length(vec) == consecutive) && (num_unique(vec) == 1)
                return true
            end
        end
    end

    # Check diagonally
    for m in 1:board_size-consecutive+1
        vec = exclude_spaces([board[n, n] for n in (m:m+consecutive-1)])
        if (length(vec) == consecutive) && (num_unique(vec) == 1)
            return true
        end

        vec = exclude_spaces([board[n, board_size-n+1] for n in m:(m+consecutive-1)])
        if (length(vec) == consecutive) && (num_unique(vec) == 1)
            return true
        end
    end

    # No winner
    return false
end


# Check for a tie
function check_tie()
    global moves, board_size, consecutive, board

    if length(moves) == 0 # No more moves
        return true
    end

    # It"s a tie if all possible row_labels, col_labels and diagonals cannot win

    for m in 1:board_size
        for n in 1:board_size-consecutive+1
            # Check by row
            vec = exclude_spaces(board[m, n:n+consecutive-1])
            if num_unique(vec) <= 1
                return false
            end

            # Check by col
            vec = exclude_spaces(board[n:n+consecutive-1, m])
            if num_unique(vec) <= 1
                return false
            end
        end
    end

    # Check diagonally
    for m in 1:(board_size-consecutive+1)
        vec = exclude_spaces([board[n, n] for n in m:(m+consecutive-1)])
        if num_unique(vec) <= 1
            return false
        end

        vec = exclude_spaces([board[n, board_size-n+1] for n in m:(m+consecutive-1)])
        if num_unique(vec) <= 1
            return false
        end
    end

    # If all checks doesn"t flag as False
    return true
end


# Get human player"s move
function human_move()
    global step, current_player, moves
    
    return uppercase(input("Step $(step): Player $(current_player), enter your move: ", vcat(moves, lowercase.(moves)), "Sorry, that is not a valid move."))
end


# Computer's move
function computer_move(player)
    global board_size, board, current_player, moves

    # Find a winning move
    for row in 1:board_size
        for col in 1:board_size
            if board[row, col] == " "
                board[row, col] = (player == "O") ? "O" : "X"
                if check_win()
                    board[row, col] = " "
                    return rowcol2move(row, col)
                end
                board[row, col] = " "
            end
        end
    end

    # Find a blocking move
    for row in 1:board_size
        for col in 1:board_size
            if board[row, col] == " "
                board[row, col] = (player == "O") ? "X" : "O"
                if check_win()
                    board[row, col] = " "
                    return rowcol2move(row, col)
                end
                board[row, col] = " "
            end
        end
    end

    # If the computer can't block the user from winning, make a random move.
    return rand(moves)
end


## Program starts

board_size = input("What board size do you want to play (3-$(Max_board_size))? ", 3:Max_board_size, "Answer must be from 3 to $(Max_board_size).")

# consecutive = board_size
# It is possible to reduce the number of consecutive cells to win
 if board_size == 3
    consecutive = 3
 else
    consecutive = input("How many consecutive cells to win (3-$(board_size))? ", 3:board_size, "Answer must be from 3 to $(board_size).")
 end

# Select play mode
play_mode = input("Select play mode: (1) Human vs computer, (2) Computer vs computer or (3) Human vs human? ", 1:3, "Answer must be 1, 2 or 3.")

# Create row and col labels
row_labels = [Char(Int('A') + i) for i in 0:(board_size-1)]
col_labels = string.(1:board_size)

global playagain_flag = true

while playagain_flag
    # Initialise game

    # Define an empty board
    global board = fill(" ", board_size, board_size)

    # Define the possible moves
    global moves = [row*col for row in row_labels for col in col_labels]
    # moves = ["A1", "A2", "A3", "B1", "B2", "B3", "C1", "C2", "C3"]

    # Define the starting current player
    global current_player = "X"

    # Define the game_state
    global game_state = "continue"

    # Define step counter
    global step = 0

    display_board()

    while game_state == "continue"
        # Increase step
        step += 1

        # Get the player's move
        if (play_mode == 1 && current_player == "X") || (play_mode == 3)
            move = human_move()
        else
            move = computer_move(current_player)
            println("Step $(step): Computer $(current_player) chooses $(move).")
        end
        register_move(move)
        display_board()

        # Check for a win or a tie
        if check_win()
            game_state = current_player
        elseif check_tie()
            game_state = "tie"  # Game ends in a tie
        end

        # Switch players
        current_player = (current_player == "X") ? "O" : "X"
    end

    # Display the winner
    if game_state == "tie"
        println("The game ends in a tie in $(step) steps.")
    elseif (play_mode == 1 && game_state == "X") || (play_mode == 3)
        println("Congratulations, you won in $(step) steps!")
    else
        println("Computer $(game_state) won in $(step) steps!")
    end

    # Ask to play again
    global playagain_flag = uppercase(input("Play again (Y/N)? ", ["Y", "N", "y", "n"], "Answer must be either Y or N.")) == "Y"
end

println("Goodbye.")

# End of program
