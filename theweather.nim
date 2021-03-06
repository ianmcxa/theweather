# Display the weather in cool terminal color
# by Ian Mcxa

import json, httpclient, strutils, colorize, os, times

const apiKey = staticExec("cat apikey.txt")
let zipCode = staticExec("cat zip.txt")

type
  CurrentWeather* = object
    temp, humidity, conditionCode: int
    condition: string

type
  ForecastWeather* = object
    highTemp, lowTemp: int

proc cacheResult(data: string): void =
  let file = open("$1/.theweathercache" % getHomeDir(), fmWrite)
  file.write(data)
  file.close()

proc checkCache(): (JsonNode, bool) =
  if (not fileExists("$1/.theweathercache" % getHomeDir())):
    return (nil, false)

  let file = open("$1/.theweathercache" % getHomeDir())
  let data = parseJson(file.readLine())

  # check if the data is up to date
  let cacheDate = fromUnix(data["dt"].getInt())
  # if the weather data is older than 1 hour, it's out of date
  if (cacheDate + 1.hours < now().toTime()):
    return (nil, false)
  else:
    return (data, true)

proc getCurrentWeather(): CurrentWeather =
  var json: JsonNode = nil

  let cache = checkCache()
  # if we got a positive response from the cache
  if (cache[1]):
    json = cache[0]
  else:
    var client = newHttpClient()
    let response = client.getContent("https://api.openweathermap.org/data/2.5/weather?zip=$2,us&appId=$1" % [apiKey, zipCode])
    cacheResult(response)

    json = parseJson(response)
  
  return CurrentWeather(temp: int(json["main"]["temp"].getFloat() * 9 / 5 - 459.67),
                        conditionCode: json["weather"][0]["id"].getInt(),
                        condition: json["weather"][0]["description"].getStr(),
                        humidity: json["main"]["humidity"].getInt())

# Print convert a temperature number to a colorized string
proc colorTemp(temp: int): string =
  if (temp > 90):
    return intToStr(temp).fgRed()
  elif (temp > 80):
    return intToStr(temp).fgLightRed()
  elif (temp > 70):
    return intToStr(temp).fgLightYellow()
  elif (temp > 60):
    return intToStr(temp).fgLightGreen()
  elif (temp > 50):
    return intToStr(temp).fgLightCyan()
  elif (temp > 40):
    return intToStr(temp).fgCyan()
  elif (temp > 30):
    return intToStr(temp).fgLightBlue()
  else:
    return intToStr(temp).fgBlue()

# Color the conditions text
proc colorConditionCode(code: int, condition: string): string =
  if (code == 804):
    return condition.fgLightGray()
  elif (code >= 800):
    return condition.fgYellow()
  elif (code >= 700):
    return condition.fgDarkGray()
  elif (code >= 600):
    return condition.fgWhite()
  elif (code >= 501):
    return condition.fgBlue()
  elif (code >= 300):
    return condition.fgLightBlue()
  elif (code >= 200):
    return condition.fgBlue()
  else:
    return condition

proc printCurrentWeather(weather: CurrentWeather): void =
  echo "Conditions: $1\tTemp: $2\tHumidity: $3" % [colorConditionCode(weather.conditionCode, weather.condition),
                                                  colorTemp(weather.temp),$weather.humidity]

proc main(): void =
  let currentWeather = getCurrentWeather()
  printCurrentWeather(currentWeather)

main()
