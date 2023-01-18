#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ My Salon ~~~~~\n"
echo -e "\nWelcome to My Salon, how can I help you?\n"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

# show available services
  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  # if there is no service available
  if [[ -z $SERVICES ]]
  then
    echo "Sorry, we don't have any service right now"
  # case there it is, show them formated
  else
    echo -e "$SERVICES" | while read SERVICE_ID BAR NAME
    do
      echo "$SERVICE_ID) $NAME"
    done
  #get customer choice
  read SERVICE_ID_SELECTED
  #if the choice is not a number
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
    then
    #send to main menu
    MAIN_MENU "Sorry, that is not a valid number! Please, choose again."
    #if it is a number but not the valid ones
    else
    VALID_SERVICE=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED")
      if [[ -z $VALID_SERVICE ]]
      then
    #send to main menu
    MAIN_MENU "I could not find that service. What would you like today?"
    else
    #get customer phone number
      echo -e "\nWhat's your phone number?"
      read CUSTOMER_PHONE
      #check if it's a new customer or not
        CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
       #if a new customer
        if [[ -z $CUSTOMER_NAME ]]
        then
        #get the name
          echo -e "\nWhat's your name?"
          read CUSTOMER_NAME
          #insert new customer
          INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')") 
          #get the time schedule
          SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
          echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
          read SERVICE_TIME
          CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
          #update the appointment table
          INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(time, customer_id, service_id) VALUES('$SERVICE_TIME', '$CUSTOMER_ID', '$SERVICE_ID_SELECTED')")
          echo -e "\nI have put you down for a $(echo $SERVICE_NAME | sed -r 's/^ *| *$//g') at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')."
        else
        #if it's old customer
          SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
          echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
          read SERVICE_TIME
          CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
          #update the appointment table
          INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(time, customer_id, service_id) VALUES('$SERVICE_TIME', '$CUSTOMER_ID', '$SERVICE_ID_SELECTED')")
          echo -e "\nI have put you down for a $(echo $SERVICE_NAME | sed -r 's/^ *| *$//g') at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')."
        fi

      fi
  fi

  fi
}


MAIN_MENU

