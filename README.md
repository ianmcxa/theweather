# The Weather

And now, I give you The Weather!

## Setting up your openweathermap api key

You'll need an openweathermap API key to compile and run the program (don't worry they're free). Place your key into the file `apikey.txt` in the
root folder of the project. Now, when you compile theweather it will pull in your api key.

## compiling

You'll need the nim compiler

`nim -d:ssl -r c theweather.nim`
