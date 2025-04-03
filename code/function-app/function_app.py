import logging
import requests
import json
from azure.eventhub import EventHubProducerClient, EventData
from azure.identity import DefaultAzureCredential
#from azure.keyvault.secrets import SecretClient 
#--this was used in the past to securely store key vault secrets
import datetime
import os
import pytz
import azure.functions as func

app = func.FunctionApp()

# Configure logging
logging.basicConfig(level=logging.INFO)


# Define your Event Hub connection details
connection_str =  "endpoint"

eventhub_name = "harsh598eventhub" #name of your instance

# Define your OpenWeather API key and endpoints
api_key = "apikey"
weather_url = "http://api.openweathermap.org/data/2.5/weather"
pollution_url = "http://api.openweathermap.org/data/2.5/air_pollution"


# Function to get real-time weather data
def get_weather_data(lat, lon, api_key):
    try:
        params = {
        #how to specify the city and the API key?
        "lat": lat,
        "lon": lon,
        "appid": api_key
        }
        response = requests.get(weather_url, params=params)
        response.raise_for_status()
        logging.info(f"Weather data response: {response.json()}")
        return response.json()
    except requests.RequestException as e:
        logging.error(f"Error fetching weather data: {e}")
        return None

# Function to get real-time air pollution data
def get_pollution_data(lat, lon, api_key):
    # copy the format of the weather data function, but using air pollution URL instead
    try:
        params = {
        #how to specify the city and the API key?
        "lat": lat,
        "lon": lon,
        "appid": api_key
        }
        response = requests.get(weather_url, params=params)
        response.raise_for_status()
        logging.info(f"Air Pollution data response: {response.json()}")
        return response.json()
    except requests.RequestException as e:
        logging.error(f"Error fetching air pollution data: {e}")
        return None


# Function to send data to Event Hub
def send_to_eventhub(data):
    try:
        producer = EventHubProducerClient.from_connection_string(conn_str=connection_str, eventhub_name=eventhub_name)
        event_data_batch = producer.create_batch()
        event_data_batch.add(EventData(json.dumps(data)))
        producer.send_batch(event_data_batch)
        producer.close()
        logging.info("Data sent to Event Hub successfully.")
    except Exception as e:
        logging.error(f"Error sending data to Event Hub: {e}")
    raise


@app.timer_trigger(schedule="0 * * * * *", arg_name="mytimer", run_on_startup=True, use_monitor=True)
def main(mytimer: func.TimerRequest) -> None:
    try:
        if mytimer.past_due:
            logging.info('The timer is past due!')
        # Get the current time in UTC and convert to EST
        utc_time = datetime.datetime.utcnow().replace(tzinfo=datetime.timezone.utc)
        est_timezone = pytz.timezone('America/New_York')
        est_time = utc_time.astimezone(est_timezone).isoformat()

        logging.info("Starting function execution...")
        lat, lon = 42.3601, -71.0589  # Coordinates for Boston

        logging.info("Fetching weather data...")
        weather_data = get_weather_data(lat, lon, api_key)
        logging.info("Fetching pollution data...")
        pollution_data = get_pollution_data(lat, lon, api_key)

        if weather_data and pollution_data:
            data = {
                "city": "Boston",
                "latitude": lat,
                "longitude": lon,
                "timestamp": est_time,
                "weather": weather_data,
                "pollution": pollution_data
            }

            logging.info(f"Data to be sent to Event Hub: {data}")
            send_to_eventhub(data)
        else:
            logging.error("Failed to retrieve weather or pollution data.")
    except Exception as e:
        logging.error(f"Error in function execution: {e}")
    
