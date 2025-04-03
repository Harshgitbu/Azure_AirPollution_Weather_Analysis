    WITH FlattenedWeather AS (
    SELECT
        System.Timestamp() AS test_datetime,
        input.weather.coord.lon AS longitude,
        input.weather.coord.lat AS latitude,
        input.weather.name AS city_name,
        input.weather.main.temp AS temperature,
        input.weather.main.feels_like AS feels_like,
        input.weather.main.pressure AS pressure,
        input.weather.main.humidity AS humidity,
        input.weather.wind.speed AS wind_speed,
        input.weather.wind.deg AS wind_direction,
        input.weather.sys.country AS country,
        input.weather.sys.sunrise AS sunrise,
        input.weather.sys.sunset AS sunset
    FROM [harsh598eventhub] AS input
    TIMESTAMP BY DATEADD(SECOND, input.weather.dt, '1970-01-01T00:00:00Z') 
    CROSS APPLY GetArrayElements(input.weather.weather) AS weather_item
)
SELECT * INTO [Harsh-workspace] FROM FlattenedWeather;
