#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "\nWelcome to My Salon, how can I help you?"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  AVAILABLE_SERVICES=$($PSQL "SELECT service_id,name FROM services ORDER BY service_id")

  # if no bikes available
  if [[ -z $AVAILABLE_SERVICES ]]
  then
    echo "Sorry, we don't have any services available right now."
  else
    # display available services
    echo -e "\nHere are the services we have available:"
    echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR NAME
    do
      echo "$SERVICE_ID) $NAME"
    done

    # ask for service
    echo -e "\nWhich service would you like?"
    read SERVICE_ID_SELECTED

    # if input is not a number
    if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
      then
      MAIN_MENU "That is not a number" 
      else
      SERV_AVAILABLE=$($PSQL "select name from services where service_id=$SERVICE_ID_SELECTED ")
      if [[ -z $SERV_AVAILABLE ]]
       then
       MAIN_MENU "I could not find that service,what would you like today?"

       else
        #get phone input
         echo -e "\nWhat's your phone number?"
         read CUSTOMER_PHONE
            CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

            # if customer doesn't exist
             if [[ -z $CUSTOMER_NAME ]]
              then
              # get new customer name
               echo -e "\nWhat's your name?"
               read CUSTOMER_NAME
               # insert new customer
               INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
            fi
            echo -e "\nWhat time would you like your $SERV_AVAILABLE,$CUSTOMER_NAME?"
            read SERVICE_TIME

            CUSTOMER_ID=$($PSQL "select customer_id from customers where phone='$CUSTOMER_PHONE' ")
            if [[ $SERVICE_TIME ]]
            then
            INSERT_SERV_RESULT=$($PSQL "insert into appointments(customer_id,service_id,time) values($CUSTOMER_ID,$SERVICE_ID_SELECTED,'$SERVICE_TIME')")
            if [[ $INSERT_SERV_RESULT ]]
            then
            echo -e "\nI have put you down for a $SERV_AVAILABLE at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')."
            fi
            fi
       fi
    fi
  fi
}

MAIN_MENU