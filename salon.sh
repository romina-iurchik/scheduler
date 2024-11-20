#! /bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

# Función para mostrar los servicios
show_services() {
  SERVICES=$($PSQL "SELECT service_id, name FROM services")
  echo -e "\nHere are the available services:"
  
  # Mostrar la lista numerada de servicios
  echo "$SERVICES" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done
}

# Función para obtener la selección del servicio
get_service_selection() {
  while true; do
    echo -e "\nPlease choose a service by entering the service number:"
    read SERVICE_ID_SELECTED
    
    # Verificar si el servicio existe
    SERVICE_EXISTS=$($PSQL "SELECT COUNT(*) FROM services WHERE service_id = $SERVICE_ID_SELECTED")
    
    if [[ $SERVICE_EXISTS -eq 1 ]]; then
      # Si el servicio existe, devolver el SERVICE_ID
      echo "You have selected service ID $SERVICE_ID_SELECTED."
      return $SERVICE_ID_SELECTED
    else
      # Si el servicio no existe, mostrar la lista de servicios nuevamente
      echo "Invalid service number. Please choose a valid service."
      show_services
    fi
  done
}

# Función para obtener el cliente
get_customer() {
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE
  
  # Verificar si el cliente ya existe
  CUSTOMER_EXISTS=$($PSQL "SELECT COUNT(*) FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  
  if [[ $CUSTOMER_EXISTS -eq 0 ]]; then
    # Si el cliente no existe, pedir nombre y registrar
    echo -e "\nWe don't have you in our system. Please provide your name:"
    read CUSTOMER_NAME
    
    # Insertar el cliente en la tabla customers
    INSERT_CUSTOMER=$($PSQL "INSERT INTO customers (name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
    
    # Obtener el customer_id recién creado
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    echo "Welcome, $CUSTOMER_NAME! Your information has been saved."
  else
    # Si el cliente ya existe, obtener el customer_id
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    
    # Obtener el nombre del cliente
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    echo "Welcome back, $CUSTOMER_NAME!"
  fi
}

# Función para crear la cita
create_appointment() {
  echo -e "\nWhat time would you like to schedule your appointment?"
  read SERVICE_TIME

  # Insertar la cita en la tabla appointments
  INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
  
  # Obtener el nombre del servicio seleccionado
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  
  # Confirmar la cita al usuario
  echo "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
}

# Mostrar la lista de servicios
show_services

# Obtener la selección del servicio
get_service_selection

# Obtener la información del cliente
get_customer

# Crear la cita
create_appointment