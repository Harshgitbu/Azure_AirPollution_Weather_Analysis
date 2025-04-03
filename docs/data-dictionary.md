# Data Dictionary

This document describes the key data elements in the weather and air pollution analytics project.

## Raw Data Collections

### Weather Data
| Field | Description | Type | Example |
|-------|-------------|------|---------|
| timestamp | Data collection time | DateTime | 2023-10-15T14:00:00Z |
| location_id | Location identifier | String | "NYC-001" |
| temperature | Temperature in celsius | Float | 22.5 |
| humidity | Relative humidity percentage | Integer | 65 |
| wind_speed | Wind speed in m/s | Float | 4.2 |
| wind_direction | Wind direction in degrees | Integer | 180 |
| pressure | Atmospheric pressure in hPa | Integer | 1012 |
| weather_condition | Weather condition code | String | "Clear" |

### Air Pollution Data
| Field | Description | Type | Example |
|-------|-------------|------|---------|
| timestamp | Data collection time | DateTime | 2023-10-15T14:00:00Z |
| location_id | Location identifier | String | "NYC-001" |
| aqi | Air Quality Index | Integer | 42 |
| pm2_5 | PM2.5 concentration (μg/m³) | Float | 12.3 |
| pm10 | PM10 concentration (μg/m³) | Float | 25.7 |
| o3 | Ozone concentration (μg/m³) | Float | 85.2 |
| no2 | Nitrogen dioxide (μg/m³) | Float | 21.8 |
| so2 | Sulfur dioxide (μg/m³) | Float | 5.4 |
| co | Carbon monoxide (μg/m³) | Float | 680.2 |

## Processed Data Tables

### Hourly_Weather_Summary
| Field | Description | Type |
|-------|-------------|------|
| date_hour | Date and hour | DateTime |
| location_id | Location identifier | String |
| avg_temp | Average temperature | Float |
| max_temp | Maximum temperature | Float |
| min_temp | Minimum temperature | Float |
| avg_humidity | Average humidity | Float |
| dominant_condition | Most frequent weather condition | String |

### Daily_Air_Quality
| Field | Description | Type |
|-------|-------------|------|
| date | Date | Date |
| location_id | Location identifier | String |
| avg_aqi | Average AQI | Float |
| max_aqi | Maximum AQI | Float |
| min_aqi | Minimum AQI | Float |
| avg_pm2_5 | Average PM2.5 | Float |
| avg_o3 | Average Ozone | Float |
| air_quality_category | Air quality category | String |

### Weather_AQ_Correlation
| Field | Description | Type |
|-------|-------------|------|
| date | Date | Date |
| location_id | Location identifier | String |
| avg_temp | Average temperature | Float |
| avg_humidity | Average humidity | Float |
| avg_aqi | Average AQI | Float |
| correlation_coefficient | Statistical correlation | Float |
