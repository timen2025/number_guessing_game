#!/bin/bash

# Set up the PSQL variable for connecting to the database
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# Prompt user for username
echo "Enter your username:"
read username

# Check if the username exists in the database
USER_EXISTS=$($PSQL "SELECT username FROM users WHERE username = '$username'")

if [[ -z $USER_EXISTS ]]; then
  # If the username doesn't exist, welcome them and add them to the database
  echo "Welcome, $username! It looks like this is your first time here."
  # Insert the new user into the database
  INSERT_USER_RESULT=$($PSQL "INSERT INTO users (username) VALUES ('$username')")
else
  # If the username exists, fetch their game stats
  GAME_STATS=$($PSQL "SELECT games_played, best_game FROM users WHERE username = '$username'")
  GAMES_PLAYED=$(echo $GAME_STATS | cut -d'|' -f1)
  BEST_GAME=$(echo $GAME_STATS | cut -d'|' -f2)
  echo "Welcome back, $username! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

# Generate a random number between 1 and 1000
SECRET_NUMBER=$((RANDOM % 1000 + 1))

# Initialize variables
GUESS_COUNT=0
GUESS=0

echo "Guess the secret number between 1 and 1000:"

# Loop until the user guesses correctly
while [[ $GUESS -ne $SECRET_NUMBER ]]; do
  read GUESS
  GUESS_COUNT=$((GUESS_COUNT + 1))

  # Check if the guess is an integer
  if ! [[ $GUESS =~ ^[0-9]+$ ]]; then
    echo "That is not an integer, guess again:"
    continue
  fi

  # Compare the guess with the secret number
  if [[ $GUESS -lt $SECRET_NUMBER ]]; then
    echo "It's higher than that, guess again:"
  elif [[ $GUESS -gt $SECRET_NUMBER ]]; then
    echo "It's lower than that, guess again:"
  fi
done

# Print success message
echo "You guessed it in $GUESS_COUNT tries. The secret number was $SECRET_NUMBER. Nice job!"

# Update user statistics in the database
UPDATE_RESULT=$($PSQL "UPDATE users SET games_played = games_played + 1, best_game = LEAST(best_game, $GUESS_COUNT) WHERE username = '$username'")
