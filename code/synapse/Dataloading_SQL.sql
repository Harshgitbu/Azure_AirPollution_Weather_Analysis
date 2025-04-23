-- ========== STEP 1: External Data Source and Format ==========
CREATE EXTERNAL DATA SOURCE HarshDataSource 
WITH (
    LOCATION = 'https://harshshahstorage.blob.core.windows.net/harshcontainer'
);
GO

CREATE EXTERNAL FILE FORMAT ParquetFileFormatted
WITH (
    FORMAT_TYPE = PARQUET
);
GO

-- ========== STEP 2: External Tables ==========

-- External table for raw weather data (matches weather_df)
CREATE EXTERNAL TABLE ExternalWeather ( 
    id NVARCHAR(100),
    location NVARCHAR(100),
    date_time DATETIME2,
    temp_K FLOAT,
    temp_max_K FLOAT,
    temp_min_K FLOAT,
    feels_like_K FLOAT,
    temp_C FLOAT,
    temp_max_C FLOAT,
    temp_min_C FLOAT,
    feels_like_C FLOAT,
    temp_F FLOAT,
    temp_max_F FLOAT,
    temp_min_F FLOAT,
    feels_like_F FLOAT,
    humidity SMALLINT,
    wind_speed FLOAT,
    weather_id_value INT,
    weather_description_value NVARCHAR(100),
    weather_icon_value NVARCHAR(10),
    weather_main_value NVARCHAR(100)
)
WITH (
    LOCATION = 'Gold/processed_weather', 
    DATA_SOURCE = HarshDataSource,
    FILE_FORMAT = ParquetFileFormatted
);
GO


-- FactWeather table (for weather_df)
CREATE TABLE FactWeather (
    id NVARCHAR(100),
    date_time DATETIME2,
    date DATE,        
    location NVARCHAR(100),
    humidity SMALLINT,
    temp_K FLOAT,
    feels_like_K FLOAT,
    temp_max_K FLOAT,
    temp_min_K FLOAT,
    temp_C FLOAT,
    feels_like_C FLOAT,
    temp_max_C FLOAT,
    temp_min_C FLOAT,
    temp_F FLOAT,
    feels_like_F FLOAT,
    temp_max_F FLOAT,
    temp_min_F FLOAT,
    weather_combined_value NVARCHAR(200)
);
GO

INSERT INTO FactWeather (id,date_time,date,location,humidity,
temp_K,feels_like_K,temp_max_K,temp_min_K,
temp_C,feels_like_C,temp_max_C,temp_min_C,
temp_F,feels_like_F,temp_max_F,temp_min_F,
weather_combined_value)
SELECT
    id,
    date_time, 
    CAST(date_time AS DATE) AS date,
    location,
    humidity, 
    temp_K, 
    feels_like_K, 
    temp_max_K, 
    temp_min_K,
    temp_C,
    feels_like_C,
    temp_max_C,
    temp_min_C,
    temp_F,
    feels_like_F,
    temp_max_F,
    temp_min_F,
    CONCAT(weather_id_value, '_', weather_icon_value) AS weather_combined_value
FROM ExternalWeather;
GO


-- External table for raw air pollution data (matches air_pollution_df)
CREATE EXTERNAL TABLE ExternalAirPollution (
    id NVARCHAR(100),
    location NVARCHAR(100),
    date_time DATETIME2,
    aqi INT,
    co FLOAT,
    nh3 FLOAT,
    no FLOAT,
    no2 FLOAT,
    o3 FLOAT,
    pm10 FLOAT,
    pm2_5 FLOAT,
    so2 FLOAT,
    o3_8hr FLOAT,
    o3_1hr FLOAT,
    pm2_5_24hr FLOAT,
    pm10_24hr FLOAT,
    co_8hr FLOAT,
    so2_1hr FLOAT,
    so2_24hr FLOAT,
    no2_1hr FLOAT,
    us_aqi INT
)
WITH (
    LOCATION = 'Gold/processed_air_pollution',
    DATA_SOURCE = HarshDataSource,
    FILE_FORMAT = ParquetFileFormatted
);
GO

-- DimAirPollution table (for air_pollution_df)
CREATE TABLE DimAirPollution (
    id NVARCHAR(100),
    aqi INT,
    co FLOAT,
    no FLOAT,
    no2 FLOAT,
    o3 FLOAT,
    so2 FLOAT,
    pm2_5 FLOAT,
    pm10 FLOAT,
    nh3 FLOAT
);
GO

INSERT INTO DimAirPollution
SELECT DISTINCT 
    id, 
    aqi, 
    co, 
    no, 
    no2, 
    o3, 
    so2, 
    pm2_5, 
    pm10, 
    nh3
FROM ExternalAirPollution;
GO


-- External table for weather condition counts (matches weather_condition_counts_df)
CREATE EXTERNAL TABLE ExternalAggWeatherConditions (
    date DATE,
    weather_main_value NVARCHAR(100),
    count INT
)
WITH (
    LOCATION = 'Gold/agg_weather_conditions',
    DATA_SOURCE = HarshDataSource,
    FILE_FORMAT = ParquetFileFormatted
);
GO

-- External table for aggregated weather (matches weather_agg_df)
CREATE EXTERNAL TABLE ExternalAggWeather (
    date DATE,
    avg_temp_F FLOAT,
    avg_humidity SMALLINT,
    avg_wind_speed FLOAT,
    max_temp_F FLOAT,
    min_temp_F FLOAT,
    weather_records BIGINT
)
WITH (
    LOCATION = 'Gold/agg_weather',
    DATA_SOURCE = HarshDataSource,
    FILE_FORMAT = ParquetFileFormatted
);
GO

-- External table for temperature extremes (matches temp_extremes_df)
CREATE EXTERNAL TABLE ExternalAggTempExtremes (
    date DATE,
    temp_max_F FLOAT,
    temp_min_F FLOAT
)
WITH (
    LOCATION = 'Gold/agg_temp_extremes',
    DATA_SOURCE = HarshDataSource,
    FILE_FORMAT = ParquetFileFormatted
);
GO

-- External table for aggregated AQI (matches aqi_agg_df)
CREATE EXTERNAL TABLE ExternalAggAQI (
    date DATE, 
    avg_us_aqi FLOAT
)
WITH (
    LOCATION = 'Gold/agg_aqi',
    DATA_SOURCE = HarshDataSource,
    FILE_FORMAT = ParquetFileFormatted
);
GO

-- External table for high pollution events (matches high_pollution_events_df)
CREATE EXTERNAL TABLE ExternalHighPollutionEvents (
    date DATE, 
    high_pollution_events INT
)
WITH (
    LOCATION = 'Gold/agg_high_pollution_events',
    DATA_SOURCE = HarshDataSource,
    FILE_FORMAT = ParquetFileFormatted
);
GO

-- External table for aggregated pollutants (matches pollutant_agg_df)
CREATE EXTERNAL TABLE ExternalAggPollutants (
    date DATE, 
    avg_co FLOAT, 
    avg_no2 FLOAT, 
    avg_o3 FLOAT, 
    avg_so2 FLOAT, 
    avg_pm2_5 FLOAT,
    avg_pm10 FLOAT
)
WITH (
    LOCATION = 'Gold/agg_pollutants',
    DATA_SOURCE = HarshDataSource,
    FILE_FORMAT = ParquetFileFormatted
);
GO



-- DimDateTime table (using date_time from ExternalWeather)
CREATE TABLE DimDateTime (
    date_time DATETIME,
    date DATE,
    year INT,
    month INT,
    day INT,
    hour INT,
    minute INT,
    second INT,
    quarter INT,
    week INT,
    day_of_week INT,
    day_name VARCHAR(10),
    month_name VARCHAR(10),
    is_weekend BIT
);
GO

INSERT INTO DimDateTime
SELECT DISTINCT 
    date_time,
    CAST(date_time AS DATE) AS date,
    DATEPART(YEAR, date_time) AS year,
    DATEPART(MONTH, date_time) AS month,
    DATEPART(DAY, date_time) AS day,
    DATEPART(HOUR, date_time) AS hour,
    DATEPART(MINUTE, date_time) AS minute,
    DATEPART(SECOND, date_time) AS second,
    DATEPART(QUARTER, date_time) AS quarter,
    DATEPART(WEEK, date_time) AS week,
    DATEPART(WEEKDAY, date_time) AS day_of_week,
    CASE 
        WHEN DATEPART(WEEKDAY, date_time) = 1 THEN 'Sunday'
        WHEN DATEPART(WEEKDAY, date_time) = 2 THEN 'Monday'
        WHEN DATEPART(WEEKDAY, date_time) = 3 THEN 'Tuesday'
        WHEN DATEPART(WEEKDAY, date_time) = 4 THEN 'Wednesday'
        WHEN DATEPART(WEEKDAY, date_time) = 5 THEN 'Thursday'
        WHEN DATEPART(WEEKDAY, date_time) = 6 THEN 'Friday'
        WHEN DATEPART(WEEKDAY, date_time) = 7 THEN 'Saturday'
        ELSE 'Unknown'
    END AS day_name,
    CASE 
        WHEN DATEPART(MONTH, date_time) = 1 THEN 'January'
        WHEN DATEPART(MONTH, date_time) = 2 THEN 'February'
        WHEN DATEPART(MONTH, date_time) = 3 THEN 'March'
        WHEN DATEPART(MONTH, date_time) = 4 THEN 'April'
        WHEN DATEPART(MONTH, date_time) = 5 THEN 'May'
        WHEN DATEPART(MONTH, date_time) = 6 THEN 'June'
        WHEN DATEPART(MONTH, date_time) = 7 THEN 'July'
        WHEN DATEPART(MONTH, date_time) = 8 THEN 'August'
        WHEN DATEPART(MONTH, date_time) = 9 THEN 'September'
        WHEN DATEPART(MONTH, date_time) = 10 THEN 'October'
        WHEN DATEPART(MONTH, date_time) = 11 THEN 'November'
        WHEN DATEPART(MONTH, date_time) = 12 THEN 'December'
        ELSE 'Unknown'
    END AS month_name,
    CASE WHEN DATEPART(WEEKDAY, date_time) IN (1, 7) THEN 1 ELSE 0 END AS is_weekend
FROM ExternalWeather;
GO

-- DimWeatherCondition table (from ExternalWeather)
CREATE TABLE DimWeatherCondition (
    weather_id_value VARCHAR(100),
    weather_icon_value VARCHAR(10),
    weather_main_value VARCHAR(100),
    weather_description_value VARCHAR(100),
    weather_combined_value VARCHAR(200)
);
GO

INSERT INTO DimWeatherCondition
SELECT  
    weather_id_value, 
    weather_icon_value, 
    weather_main_value, 
    weather_description_value,
    CONCAT(weather_id_value, '_', weather_icon_value) AS weather_combined_value
FROM ExternalWeather;
GO

-- DimDate table (from DimDateTime)
CREATE TABLE DimDate (
    date_time DATETIME,
    date DATE,
    year INT,
    month INT,
    day INT,
    day_of_week INT,
    day_name VARCHAR(10),
    month_name VARCHAR(10)
);
GO

INSERT INTO DimDate
SELECT DISTINCT 
    date_time,
    date,
    year,
    month,
    day,
    day_of_week,
    day_name,
    month_name
FROM DimDateTime;
GO

-- AggTempExtremes table (from temp_extremes_df)
CREATE TABLE AggTempExtremes (
    date DATETIME2,
    temp_min_F FLOAT,
    temp_max_F FLOAT
);
GO

INSERT INTO AggTempExtremes 
SELECT 
    date,
    temp_min_F, 
    temp_max_F
FROM ExternalAggTempExtremes;
GO

-- AggWeatherConditions table (updated with weather_main_value column)
CREATE TABLE AggWeatherConditions (
    date DATE,
    weather_main_value NVARCHAR(100),
    count INT
);
GO

INSERT INTO AggWeatherConditions
SELECT 
    date,
    weather_main_value,
    count(weather_main_value) as counts
FROM 
    ExternalAggWeatherConditions
GROUP BY 
    date,
    weather_main_value;
GO

-- AggWeather table (from weather_agg_df)
CREATE TABLE AggWeather (
    date DATE,
    avg_temp_F FLOAT,
    avg_humidity SMALLINT,
    avg_wind_speed FLOAT,
    max_temp_F FLOAT,
    min_temp_F FLOAT,
    weather_records BIGINT
);
GO

INSERT INTO AggWeather
SELECT 
    date,
    avg_temp_F,
    avg_humidity,
    avg_wind_speed,
    max_temp_F,
    min_temp_F,
    weather_records
FROM ExternalAggWeather;
GO

-- HighPollutionEvents table (from high_pollution_events_df)
CREATE TABLE HighPollutionEvents (
    date DATE, 
    high_pollution_events INT
);
GO

INSERT INTO HighPollutionEvents
SELECT 
    date,
    count(high_pollution_events) as high_pollution_events
FROM 
    ExternalHighPollutionEvents
GROUP BY
    date;
GO

-- AggPollutants table (from pollutant_agg_df)
CREATE TABLE AggPollutants (
    date DATE,
    avg_co FLOAT, 
    avg_no2 FLOAT, 
    avg_o3 FLOAT, 
    avg_so2 FLOAT, 
    avg_pm2_5 FLOAT,
    avg_pm10 FLOAT
);
GO

INSERT INTO AggPollutants
SELECT 
    date,
    avg_co,
    avg_no2,
    avg_o3,
    avg_so2,
    avg_pm2_5,
    avg_pm10
FROM ExternalAggPollutants;
GO

-- AggAQI table (from aqi_agg_df)
CREATE TABLE AggAQI (
    date DATE,
    avg_us_aqi FLOAT
);
GO

INSERT INTO AggAQI
SELECT 
    date,
    avg_us_aqi
FROM 
    ExternalAggAQI
--GROUP BY
    --date_time
GO

CREATE TABLE DimLocation (
-- An aggregated table for Air Quality Index (AQI) data.
-- Contains average AQI values for each date.
    location VARCHAR(20)
);
GO

INSERT INTO DimLocation
SELECT
    location
FROM 
    ExternalWeather
--GROUP BY
    --date_time
GO


SELECT TOP 10 * FROM FactWeather;
SELECT TOP 10 * FROM DimLocation;
SELECT TOP 10 * FROM DimAirPollution;
SELECT TOP 10 * FROM DimWeatherCondition;
SELECT TOP 10 * FROM DimDateTime;
SELECT TOP 10 * FROM DimDate;
SELECT TOP 10 * FROM AggWeather;
SELECT TOP 10 * FROM AggWeatherConditions;
SELECT TOP 10 * FROM AggTempExtremes;
SELECT TOP 10 * FROM AggAQI;
SELECT TOP 10 * FROM AggPollutants;
SELECT TOP 10 * FROM HighPollutionEvents;
