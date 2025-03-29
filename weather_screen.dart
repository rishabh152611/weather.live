import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wether_new/secreats.dart';
import 'hourly_forecast_item.dart';
import 'additional_info_item.dart';
import 'package:http/http.dart' as http;

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  Future<Map<String, dynamic>> getCurrentWeather() async {
    try {
      // Change the city name as desired
      String cityName = 'Ghaziabad';
      final res = await http.get(
        Uri.parse(
          'http://api.openweathermap.org/data/2.5/forecast?q=$cityName&APPID=$openWeatherAPIKey',
        ),
      );
      final data = jsonDecode(res.body);
      if (data['cod'] != "200") {
        throw 'An unexpected error occurred';
      }
      return data;
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Vibrant gradient colors for your background.
    const Gradient backgroundGradient = LinearGradient(
      colors: [
        Color(0xffFF6B6B), // Vibrant red
        Color(0xffFFD93D), // Bright yellow
        Color(0xff6BCB77), // Vivid green
        Color(0xff4D96FF), // Bright blue
        Color(0xff845EC2), // Bold purple
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        shadowColor: Colors.grey,
        backgroundColor: Colors.transparent,
        elevation: 0.1,
        title: const Text(
          'Weather App',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.normal,
            fontSize: 24,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {}); // Refresh content.
            },
            icon: const Icon(
              Icons.refresh,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: backgroundGradient,
        ),
        child: RefreshIndicator(
          color: Colors.white,
          backgroundColor: Colors.black26,
          onRefresh: () async {
            setState(() {});
          },
          child: Padding(
            padding: const EdgeInsets.only(top: 70.0),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 24,
                ),
                child: FutureBuilder(
                  future: getCurrentWeather(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator.adaptive(),
                      );
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          snapshot.error.toString(),
                          style: const TextStyle(
                              color: Colors.white, fontSize: 18),
                        ),
                      );
                    }

                    final data = snapshot.data!;

                    // Extract the city name from the response.
                    final currentCity = data['city']['name'];

                    final currentWeatherData = data['list'][0];

                    // Convert and calculate temperatures
                    final double currentTempK =
                        (currentWeatherData['main']['temp'] as num).toDouble();
                    final double currentTempC = currentTempK - 273.15;
                    final currentSky = currentWeatherData['weather'][0]['main'];
                    final currentPressure =
                        currentWeatherData['main']['pressure'];
                    final currentWindSpeed =
                        currentWeatherData['wind']['speed'];
                    final currentHumidity =
                        currentWeatherData['main']['humidity'];

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Display the current city name between the AppBar and the main content.
                        Text(
                          currentCity,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Vibrant Weather Info Card with a frosted glass effect.
                        SizedBox(
                          width: double.infinity,
                          child: Card(
                            elevation: 12,
                            color: Colors.white.withOpacity(0.3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: BackdropFilter(
                                filter:
                                    ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 36,
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        "${currentTempC.toStringAsFixed(1)} °C",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 26,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      Icon(
                                        (currentSky == 'Rain' ||
                                                currentSky == 'Clouds')
                                            ? Icons.cloud
                                            : Icons.wb_sunny,
                                        size: 70,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(height: 20),
                                      Text(
                                        currentSky,
                                        style: const TextStyle(
                                          fontSize: 26,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Hourly Forecast',
                          style: TextStyle(
                            fontSize: 26,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 140,
                          child: ListView.builder(
                            itemCount: 5,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, index) {
                              final hourlyForecast = data['list'][index + 1];
                              final double hourlyTempK =
                                  (hourlyForecast['main']['temp'] as num)
                                      .toDouble();
                              final double hourlyTempC = hourlyTempK - 273.15;
                              final hourlySky =
                                  hourlyForecast['weather'][0]['main'];
                              final time =
                                  DateTime.parse(hourlyForecast['dt_txt'])
                                      .toLocal();

                              return HourlyForecastItem(
                                time: DateFormat.Hm().format(time),
                                temperature:
                                    "${hourlyTempC.toStringAsFixed(1)} °C",
                                icon: (hourlySky == 'Clouds' ||
                                        hourlySky == 'Rain')
                                    ? Icons.cloud
                                    : Icons.wb_sunny,
                                // You may want to update the HourlyForecastItem widget further
                                // to style it in a vibrant way using your preferred colors.
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 40),
                        const Text(
                          'Additional Information',
                          style: TextStyle(
                            fontSize: 30,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            AdditionalInfoItems(
                              icon: Icons.water_drop,
                              label: 'Humidity',
                              value: currentHumidity.toString(),
                            ),
                            AdditionalInfoItems(
                              icon: Icons.air,
                              label: 'Wind Speed',
                              value: currentWindSpeed.toString(),
                            ),
                            AdditionalInfoItems(
                              icon: Icons.speed,
                              label: 'Pressure',
                              value: currentPressure.toString(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
