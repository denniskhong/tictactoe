#!/usr/bin/env julia

# Tic Tac Toe
# Author: Dennis W. K. Khong <denniswkkhong@gmail.com>
# Some comments were suggested by ChatGPT.
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
    """
    Function to convert user move to row and column values in the board.
    Only accepts a single character row label.
    """
    return (Int(move[1])-64), tryparse(Int64, move[2:length(move)])
end


# Convert row and col to move
function rowcol2move(row, col)
    """
    Function to convert row and column values to user move in a string
    """
    return row_labels[row] * col_labels[col]
end


# Register a move
function register_move(move)
    """
    Function to register a move by updating the board and removing the move from the available moves in vector moves.
    String move is a valid user-entered move.
    """
    global board, current_player, moves
    
    # Convert user-entered move to row and column numbers
    row, col = move2rowcol(move)
    # Add the player's symbol into the board based on the row and column number
    board[row, col] = current_player
    # Update list of remaining valid moves by filtering out the registered move
    moves = filter(s -> s != move, moves)  # Uses lambda expression
end


# Display board
function display_board()
    """
    Function to display the board on the console.
    Row and column labels are not part of the board array, but are
    kept in separate row_labels and col_labels vectors.
    """
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
    """
    Function to remove spaces from a vector.
    """
    return filter(s -> !(s in [' ', " "]), vec)
end


# Get number of unique items excluding spaces
function num_unique(vec)
    """
    Function to count the number of unique items in a vector, excluding spaces.
    """
    return length(unique(vec))
end


# Check for a win
function check_win()
    """
    Function to check if the game has been won by any player. It checks the rows, columns, and diagonals for a consecutive number of similar symbols.
    A winning position is found if consecutive cells contain the same symbol of a player. The winner is assumed to be the last current_player before the call.
    """

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
    """
    Function to check the board whether a tie has occurred.
    A tie occurs when there is no more possible winning moves in rows, columns and diagonally.
    First, if there is no more moves available, then a tie condition occurs.
    Alternatively, consecutive cells remain a possible winning move when it only has one player or no player. When a possbible winning move is found, check_tie() immediately returns a false value. Only when the whole board has been completely checked for possible winning moves and none has been found then check_tie() will return a true value.
    """
    
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


# Get human player's move
function human_move()
    """
    Function to allow a human player to enter a move.
    User entry is validated against the vector moves containing all possible moves, for both upper case and lower case moves.
    Return the uppercase of validated user input.
    """

    global step, current_player, moves
    
    return uppercase(input("Step $(step): Player $(current_player), enter your move: ", vcat(moves, lowercase.(moves)), "Sorry, that is not a valid move."))
end


# Computer's move
function computer_move(player)
    """
    Function for computer player to enter a valid move.
    First, it checks for a possible winning move by playing available moves to see if a winning move is possible. If a win is found, then return the winning move.
    Then, it check for a blocking move by playing available moves to see if a winning move by the opponent is possible. If a blocking move is found, then return the blocking move.
    Finally, if neither a winning move or a blocking move is found, then return a random move from the vector of possible moves.
    """

    global board_size, board, current_player, moves

    # Find a winning move
    for m in moves
        row, col = move2rowcol(m)
        board[row, col] = (player == "O") ? "O" : "X"
        if check_win()
            board[row, col] = " "
            return m
        end
        board[row, col] = " "
    end

    # Find a blocking move
    for m in moves
        row, col = move2rowcol(m)
        board[row, col] = (player == "O") ? "X" : "O"
        if check_win()
            board[row, col] = " "
            return m
        end
        board[row, col] = " "
    end
    
    # If the computer can't block the user from winning, make a random move.
    return rand(moves)
end


## Program starts

#Initializes the game board, available moves, and current player.
#Then, it runs the game in a loop until a player wins or the game ends
#in a draw. Inside the loop, it displays the current board, prompts the
#current player for a move, registers the move, checks for a win, and
#updates the current player. If the game ends, it displays the result
#and prompts the user to play again.


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
