#! /bin/bash
PSQL="psql --username=freecodecamp --dbname=salon --no-align --tuples-only -c"
echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "Welcome to My Salon, how can I help you?"
echo


PRINT_SERVICES() {
  SERVICES_RESULT=$($PSQL "SELECT service_id,name FROM services")
  echo "$SERVICES_RESULT" | while read SERVICE
  do
    echo "$SERVICE" | sed -r 's/\|/) /'
  done
}
PRINT_SERVICES


CHOOSE_A_SERVICE(){

  # input service_id and get service name (if it exists)
  read SERVICE_ID_SELECTED
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")

  # service does not exist?
  if [[ -z $SERVICE_NAME ]]
  then
    echo -e "\nI could not find that service. What would you like today?"
    PRINT_SERVICES
    CHOOSE_A_SERVICE
  else

    # input phone number
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE
    CUSTOMER_PHONE_RESULT=$($PSQL "SELECT phone FROM customers WHERE phone='$CUSTOMER_PHONE'")

    # phone does not exist?
    if [[ -z $CUSTOMER_PHONE_RESULT ]]
    then

      # input name (because phone does not exist)
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME

      # insert customer
      INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
    fi

    # get customer's id and name
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")

    # input appointment time
    echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
    read SERVICE_TIME
    
    # insert appointment
    INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

    # appointment confirmation
    echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
    echo
  fi
}
CHOOSE_A_SERVICE
