#!/usr/bin/env python3

# Tic Tac Toe
# This Python program uses pseudo one-base indexing
# Author: Dennis W. K. Khong <denniswkkhong@gmail.com>
# Github: https://github.com/denniskhong/tictactoe
# Date: 2023-04-29
# License: GPL 3.0

import random, sys
from numpy import unique

# Define range function with 1-based indexing
def range_uno(start, stop=None, step=1):
    '''
    Function range_uno([start=1], stop, [step=1])
    Argument start by default will start at 1, and the list generated 
    will stop at the value of stop, inclusive. The purpose of this
    function is to implement the range function by 
    (1) using one-base indexing, and 
    (2) stop at the stop value and not before.
    '''
    if stop == None:  # Only one argument given
        stop, start = start, 1
    #end if
    if step>0:
        return list(range(start, stop+1, step))
    elif step<0:
        return list(range(start, stop-1, step))
    #end if
#end def


# Define validated_input function
def validated_input(prompt, validate=None, errmessage='Invalid response.'):
    '''
    Function validated_input(prompt, [validate], [errmessage='Invalid response.'])
    Implements the input function by:
    (1) Validating the response in a validate vector,
    (2) Returning response in the same type as the element of validate
    vector,
    (3) If no value for validate is provided, then no validating is made,
    (4) Providing a default error message.
    
    '''
    if type(validate) != None:
        validate_type = type(validate[0])
    else:
        validate_type = None
    #end if
    
    if validate_type == int or validate_type == float:
        validate = [str(n).upper() for n in validate]
    #end if

    if validate_type == None:
        return input(question)
    else:
        while True:
            response = input(prompt)
            if response.upper() in validate:
                if validate_type == int:
                    return int(response)
                elif validate_type == float:
                    return float(response)
                else:
                    return response
                #end if
            else:
                print(errmessage)
            #end if
        #end while loop
    #end if
#end def


# Convert moves to row and col
def move2rowcol(move):
    return (rows.index(move[0]), cols.index(move[1:]))
#end def


# Convert row and col to move
def rowcol2move(row, col):
    return rows[row] + cols[col]
#end def


# Register a move
def register_move(move):
    row, col = move2rowcol(move)
    board[row][col] = current_player
    moves.remove(move)
#end def


# Display board
def display_board():
    for r in range_uno(0, size*2+2):
        for c in range_uno(0, size+1):
            if r == 0 and c == 0:
                print('┌───', end='')
            elif r == 0 and c == size+1:
                print('┐')
            elif r == 0:
                print('┬───', end='')
            elif r == size*2+2 and c == 0:
                print('└───', end='')
            elif r == size*2+2 and c == size+1:
                print('┘')
            elif r == size*2+2:
                print('┴───', end='')
            elif r % 2 != 0 and c == size+1: # Odd number row
                print('│')
            elif r % 2 != 0: 
                print('│ {} '.format(board[int(r/2)][c]), end='')
            elif r % 2 == 0 and c == 0: # Even number row
                print('├───', end='')
            elif r % 2 == 0 and c == size+1: 
                print('┤') 
            elif r % 2 == 0:
                print('┼───', end='')
            #end if
        #end for c
    #end for r
    print('') # Print line break
#end def


# Exclude spaces
def exclude_spaces(vec):
    return [i for i in vec if i != ' ']
#end def


# Get number of unique items excluding spaces
def num_unique(vec):
    return len(unique(vec))
#end def


# Check for a win
def check_win():
    # Check by row and col
    for m in range_uno(size):
        for n in range_uno(size-consecutive+1):
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
    for m in range_uno(size-consecutive+1):
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
#end def


# Check for a tie
def check_tie():
    if len(moves) == 0: # No more moves
        return True
    #end if

    # It's a tie if all possible rows, cols and diagonals cannot win

    for m in range_uno(size):
        for n in range_uno(size-consecutive+1):
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
    for m in range_uno(size-consecutive+1):
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
#end def


# Get human player's move
def human_move():
    return validated_input('Step {}: Player {}, enter your move: '.format(step, current_player), moves+[s.lower() for s in moves], 'Sorry, that is not a valid move.').upper()
#end def


# Computer's move
def computer_move(player):
    # Find a winning move
    for row in range_uno(size):
        for col in range_uno(size):
            if board[row][col] == ' ':
                if player == 'O':
                    board[row][col] = 'O'
                else:
                    board[row][col] = 'X'
                #end if
                if check_win():
                    board[row][col] = ' '
                    return rowcol2move(row, col)
                #end if
                board[row][col] = ' '
            #end if
        #end for col
    #end for row

    # Find a blocking move
    for row in range_uno(size):
        for col in range_uno(size):
            if board[row][col] == ' ':
                if player == 'O':
                    board[row][col] = 'X'
                else:
                    board[row][col] = 'O'
                #end if
                if check_win():
                    board[row][col] = ' '
                    return rowcol2move(row, col)
                #end if
                board[row][col] = ' '
            #end if
        #end for col
    #end for row

    # If the computer can't block the user from winning, make a random move.
    while True:
        move = random.choice(moves)
        if move not in board:
            break
        #end if
    #end loop
    return move
#end def


## Program starts

size = validated_input('What board size do you want to play (3-9)? ', [n for n in range_uno(3,9)], 'Answer must be from 3 to 9.')

consecutive = size
# It is possible to reduce the number of consecutive cells to win
# if size == 3:
    # consecutive = 3
# else:
    # consecutive = validated_input('How many consecutive cells to win (3-{})? '.format(size), [n for n in range_uno(3,size)], 'Answer must be from 3 to {}.'.format(size))
# #end if

# Select play mode
play_mode = validated_input('Select play mode: (1) Human vs computer, (2) Computer vs computer or (3) Human vs human? ', [1, 2, 3], 'Answer must be 1, 2 or 3.')

while True:
    # Initialise game

    # Define an empty board
    board = [[' ']*(size+1) for _ in range_uno(0, size)]
    
    rows = [' ']
    for n in range_uno(size):
        rows.append(chr(ord('A') + n - 1))
    #end for
    
    cols = [' ']
    for n in range_uno(size):
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
        #end if
        register_move(move)
        display_board()
        
        # Check for a win or a tie
        if check_win():
            game_status = current_player
            break
        #end if
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
    if validated_input('Play again (Y/N)? ', ['Y', 'N', 'y', 'n'], 'Answer must be either Y or N.').upper() == 'N':
        break
    #end if
#end loop

print('Good bye.')
#end program
