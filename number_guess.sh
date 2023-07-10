#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=number_guess -t --tuples-only --no-align -c"


# Finding User
  echo -e "\nEnter your username:"
  read NAME
  USERNAME_DB=$($PSQL "SELECT username FROM users WHERE username = '$NAME'")
    if [[ -z $USERNAME_DB ]]
    then
      # Entering new User to Database
      INSERT_USERNAME=$($PSQL "INSERT INTO users(username) VALUES ('$NAME')")

      # Getting new User ID
      NEW_USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$NAME'")
      
      # Welcome New User
      echo -e "\nWelcome, $NAME! It looks like this is your first time here.\n" 

    else
      # Getting returning User Info
      RETURN_USER=$($PSQL "SELECT username, MAX(games_played), MIN(number_of_guesses) FROM games FULL JOIN users USING(user_id) WHERE username = '$USERNAME_DB' GROUP BY username")
      echo "$RETURN_USER" | while IFS="|" read USER GAMES BEST
      do
        echo -e "\nWelcome back, $USER! You have played $GAMES games, and your best game took $BEST guesses.\n"
      done
    fi

# Get User ID
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$NAME'")

# Update Played game 
  GAMES_PLAYED=$($PSQL "SELECT MAX(games_played) FROM games WHERE user_id = $USER_ID ")
  UPDATED_GAMES_PLAYED=$($PSQL "SELECT $GAMES_PLAYED + 1")


# Generate random number to guess
  SECRET_NUMBER=$(( $RANDOM % 1000 + 1 ))

# Begin the Guessing Game
  echo "Guess the secret number between 1 and 1000:"
  read GUESS
  NUM_GUESS=1

  until [[ $GUESS =~ ^[0-9]+$ ]]
  do
    echo -e "That is not an integer, guess again:"
    read GUESS
  done

  until [ $GUESS -eq $SECRET_NUMBER ]
  do
    if [ $GUESS -ne $SECRET_NUMBER ]
    then
      (( NUM_GUESS++ ))
      if [ $GUESS -gt $SECRET_NUMBER ]
      then
        echo -e "\nIt's lower than that, guess again:"
        read GUESS
          while [[ ! $GUESS =~ ^[0-9]+$ ]]
          do
            echo -e "\nThat is not an integer, guess again:"
            read GUESS
          done
      else
        echo -e "\nIt's higher than that, guess again:"
        read GUESS
        while [[ ! $GUESS =~ ^[0-9]+$ ]]
        do
          echo -e "\nThat is not an integer, guess again:"
          read GUESS
        done
      fi
    else 
      echo -e "\nYou guessed it in $NUM_GUESS tries. The secret number was $SECRET_NUMBER. Nice job!\n"
    fi
  done
  echo -e "\nYou guessed it in $NUM_GUESS tries. The secret number was $SECRET_NUMBER. Nice job!\n"


# Insert Game Data to Database
  INSERT_THIS_GAME=$($PSQL "INSERT INTO games(games_played, secret_number, number_of_guesses, user_id) VALUES ($UPDATED_GAMES_PLAYED, $SECRET_NUMBER, $NUM_GUESS, $USER_ID)")