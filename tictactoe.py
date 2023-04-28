#!/usr/bin/env python3

# Tic Tac Toe
# This Python program uses pseudo one-base indexing
# Author: Dennis W. K. Khong
# Date: 2023-04-28

import random, sys
from numpy import unique

# Convert moves to row and col
def move2rowcol(move):
    return (rows.index(move[0]), cols.index(move[1:]))
#end move2rowcol()


# Convert row and col to move
def rowcol2move(row, col):
    return rows[row] + cols[col]
#end rowcol2move()


# Define verified_input function
def verified_input(question, vec):
    vec_type = type(vec[0])
    if vec_type == int or vec_type == float:
        vec = [str(n) for n in vec]
    #end if
    
    while True:
        response = input(question).upper()
        if response in vec:
            if vec_type == int:
                return int(response)
            elif vec_type == float:
                return float(response)
            else:
                return response
            #end if
        else:
            print('Invalid response.')
        #end if
    #end loop
#end verified_input()


# Register a move
def register_move(move):
    row, col = move2rowcol(move)
    board[row][col] = current_player
    moves.remove(move)
#end register_move()


# Display board
def display_board():
    for row in range(size*2+3):
        for col in range(size+2):
            if row == 0 and col == 0:
                print('┌───', end='')
            elif row == 0 and col == size+1:
                print('┐')
            elif row == 0:
                print('┬───', end='')
            elif row == size*2+2 and col == 0:
                print('└───', end='')
            elif row == size*2+2 and col == size+1:
                print('┘')
            elif row == size*2+2:
                print('┴───', end='')
            elif row % 2 != 0 and col == size+1: # Odd number row
                print('│')
            elif row % 2 != 0: 
                print('│ {} '.format(board[int(row/2)][col]), end='')
            elif row % 2 == 0 and col == 0: # Even number row
                print('├───', end='')
            elif row % 2 == 0 and col == size+1: 
                print('┤') 
            elif row % 2 == 0:
                print('┼───', end='')
            #end if
        #end for
    #end for
    print('')
#end display_board()


# Exclude spaces
def exclude_spaces(vec):
    return [i for i in vec if i != ' ']
#end exclude_spaces()


# Get number of unique items excluding spaces
def num_unique(vec):
    return len(unique(vec))
#end num_unique()


# Check for a win
def check_win():
    # Check by row and col
    for m in range(1, size+1):
        for n in range(1, size-consecutive+2):
            # create row vector
            vec = exclude_spaces(board[m][n:n+consecutive])
            if (len(vec) == consecutive) and (num_unique(vec) == 1):
                return True
            #end if
           
            # create col vector
            vec = exclude_spaces([board[p][m] for p in range(n, n+consecutive)])
            if (len(vec) == consecutive) and (num_unique(vec) == 1):
                return True
            #end if
        #end for m
    #end for n
    
    # Check diagonally
    for m in range(1, size-consecutive+2):
        vec = exclude_spaces([board[n][n] for n in range(m, m+consecutive)])
        if (len(vec) == consecutive) and (num_unique(vec) == 1):
            return True
        #end if
        
        vec = exclude_spaces([board[n][size-n+1] for n in range(m, m+consecutive)])
        if (len(vec) == consecutive) and (num_unique(vec) == 1):
            return True
        #end if
    #end for m

    # No winner
    return False
#end check_win()


# Check for a tie
def check_tie():
    if len(moves) == 0: # No more moves
        return True

    # It's a tie if all possible rows, cols and diagonals cannot win

    for m in range(1, size+1):
        for n in range(1, size-consecutive+2):
            # Check by row
            vec = exclude_spaces(board[m][n:n+consecutive])
            if num_unique(vec) < 2:
                return False
            #end if
            
            # Check by col
            vec = exclude_spaces([board[p][m] for p in range(n, n+consecutive)])
            if num_unique(vec) < 2:
                return False
            #end if
        #end for n
    #end for m
    
    # Check diagonally
    for m in range(1, size-consecutive+2):
        vec = exclude_spaces([board[n][n] for n in range(m, m+consecutive)])
        if num_unique(vec) < 2:
            return False
        #end if
        
        vec = exclude_spaces([board[n][size-n+1] for n in range(m, m+consecutive)])
        if num_unique(vec) < 2:
            return False
        #end if

    # If all checks doesn't flag as False
    return True
#end check_tie()


# Get human player's move
def human_move():
    return verified_input('Step {}: Player {}, enter your move: '.format(step, current_player), moves)
#end get_move()


# Computer's move
def computer_move(player):
    # Find a winning move
    for row in range(1,size+1):
        for col in range(1,size+1):
            if board[row][col] == ' ':
                if player == 'O':
                    board[row][col] = 'O'
                else:
                    board[row][col] = 'X'
                #end if
                if check_win():
                    board[row][col] = ' '
                    return rowcol2move(row, col)
                board[row][col] = ' '

    # Find a blocking move
    for row in range(1,size+1):
        for col in range(1,size+1):
            if board[row][col] == ' ':
                if player == 'O':
                    board[row][col] = 'X'
                else:
                    board[row][col] = 'O'
                #end if
                if check_win():
                    board[row][col] = ' '
                    return rowcol2move(row, col)
                board[row][col] = ' '

    # If the computer can't block the user from winning, make a random move.
    while True:
        move = random.choice(moves)
        if move not in board:
            break
    #end loop
    return move
#end computer_move()


## Program starts

size = verified_input('What board size do you want to play (3-9)? ', [n for n in range(3,10)])

consecutive = size
# It is possible to reduce the number of consecutive cells to win
# if size == 3:
    # consecutive = 3
# else:
    # consecutive = verified_input('How many consecutive cells to win (3-{})? '.format(size), [n for n in range(3,size+1)])
# #end if

# Select play mode
play_mode = verified_input('Select play mode: (1) Human vs computer, (2) Computer vs computer or (3) Human vs human? ', [1, 2, 3])

while True:
    # Initialise game

    # Define an empty board
    board = [[' ']*(size+1) for _ in range(size+1)]
    
    rows = [' ']
    for n in range(size):
        rows.append(chr(ord('A') + n))
    #end for
    
    cols = [' ']
    for n in range(1, size+1):
        cols.append(str(n))
    #end for
    
    board[0] = cols
    for row in range(len(rows)):
        board[row][0] = rows[row]
    #end for

    # Define the possible moves
    moves = []
    for row in rows[1:]:
        for col in cols[1:]:
            moves.append(row+col)
        #end for
    #end for
    # moves = ['A1', 'A2', 'A3', 'B1', 'B2', 'B3', 'C1', 'C2', 'C3']           

    # Define the starting current player
    current_player = 'X'

    # Define the game_status
    game_status = None
    
    # Define step counter
    step = 1

    display_board()

    while (not game_status):
        # Get the player's move
        if (play_mode == 1 and current_player == 'X') or (play_mode == 3):
            move = human_move()
        else:
            move = computer_move(current_player)
            print('Step {}: Computer {} chooses {}.'.format(step, current_player, move))
        register_move(move)
        display_board()
        
        # Check for a win or a tie
        if check_win():
            game_status = current_player
            break
        if check_tie():
            game_status = 'TIE'
            break
        #end if
            
        # Switch players
        if current_player == 'X':
            current_player = 'O'
        else:
            current_player = 'X'
        #end if
        
        # Increase step
        step += 1
    #end while

    # Display the winner
    if game_status == 'TIE':
        print('The game ends in a tie in {} steps.'.format(step))
    elif (play_mode == 1 and game_status == 'X') or (play_mode == 3):
        print('Congratulations, player {} is the winner in {} steps!'.format(game_status, step))
    else:
        print('The winner is computer {} in {} steps!'.format(game_status, step))
    #end if
    
    # Ask to play again
    if verified_input('Play again (Y/N)? ', ['Y', 'N']) == 'N':
        break
    #end if
#end loop

print('Good bye.')
#end program