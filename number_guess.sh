#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

SECRET_NUMBER=$(( ( RANDOM % 1000 )  + 1 ))
echo $SECRET_NUMBER
# initialize guesses to 0
GUESSES=0
# player name
echo -e "Enter your username:"
read NAME
  USERNAME=$($PSQL "SELECT username FROM games WHERE username='$NAME'")
  if [[ -z $USERNAME ]] 
  then 
    # new player
    USERNAME=$NAME
    # set default score of 1000
    BEST_GAME=1000
    echo $($PSQL "INSERT INTO games(username, games_played, best_game) VALUES ('$USERNAME', 1, 1000)")
    echo "Welcome, $USERNAME! It looks like this is your first time here."
  else
    # returning player
    GAMES_PLAYED=$($PSQL "SELECT games_played FROM games WHERE username='$USERNAME'")
    BEST_GAME=$($PSQL "SELECT best_game FROM games WHERE username='$USERNAME'")
    # print Welcome back, <username>! You have played <games_played> games, and your best game took <best_game> guesses.
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
    # update number of games played in database
    ((GAMES_PLAYED++))
    echo $($PSQL "UPDATE games SET games_played=$GAMES_PLAYED WHERE username='$USERNAME'")
  fi
# play the game
echo -e "Guess the secret number between 1 and 1000:"
while true
do
  # read guess from player
  read GUESS
  # incriment guesses
  ((GUESSES++))
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    # not an integer
    echo -e "That is not an integer, guess again:"
  else 
    # higher number
    if [[ $GUESS -lt $SECRET_NUMBER ]] 
    then
      echo -e "It's higher than that, guess again:"
    # lower number
    elif [[ $GUESS -gt $SECRET_NUMBER ]]
    then
      echo -e "It's lower than that, guess again:"
    else 
      # update score
      if [[ $GUESSES -lt $BEST_GAME ]]
      then
        echo $($PSQL "UPDATE games SET best_game=$GUESSES WHERE username='$USERNAME'")
      fi
      echo "You guessed it in $GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
      exit 
    fi
  fi
done 