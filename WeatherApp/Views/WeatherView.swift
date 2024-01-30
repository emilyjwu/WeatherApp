//
//  WeatherView.swift
//  WeatherApp
//
//  Created by Emily Wu on 1/30/24.
//

import SwiftUI
import CoreLocation
import FirebaseAuth

// Define the ContentView struct, which represents the main view
struct WeatherView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var weatherData: WeatherData?
    @Binding var userID: String
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [.blue, .white], startPoint: .topLeading, endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
            VStack {
                // Display weather information if available
                if let weatherData = weatherData {
                    Text("\(Int(weatherData.temperature))°C")
                        .font(.custom("", size: 70))
                        .padding()
                    
                    VStack {
                        Text("\(weatherData.locationName)")
                            .font(.title2).bold()
                        Text("\(weatherData.condition)")
                            .font(.body).bold()
                            .foregroundColor(.gray)
                    }
                    Spacer()
                } else {
                    ProgressView()
                }
                
                Button(action: {
                    let firebaseAuth = Auth.auth()
                    do {
                        try firebaseAuth.signOut()
                        withAnimation {
                            userID = ""
                        }
                    } catch let signOutError as NSError {
                        print("Error signing out: %@", signOutError)
                    }
                }) {
                    Text("Sign Out")
                        .font(.title3).bold()
                }
                            
            }
            .frame(width: 300, height: 300)
            .background(.ultraThinMaterial)
            .cornerRadius(20)
            .onAppear {
                // Request location when the view appears
                locationManager.requestLocation()
            }
            .onReceive(locationManager.$location) { location in
                // Fetch weather data when the location is updated
                guard let location = location else { return }
                fetchWeatherData(for: location)
            }
        }
    }
    
    // Fetch weather data for the given location
    private func fetchWeatherData(for location: CLLocation) {
        let apiKey = "23a285d3ac414fa7f3e97cd445025aeb"
        let urlString = "https://api.openweathermap.org/data/2.5/weather?lat=\(location.coordinate.latitude)&lon=\(location.coordinate.longitude)&units=metric&appid=\(apiKey)"
        
        guard let url = URL(string: urlString) else { return }
        
        // Make a network request to fetch weather data
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data else { return }
            
            do {
                let decoder = JSONDecoder()
                let weatherResponse = try decoder.decode(WeatherResponse.self, from: data)
                
                DispatchQueue.main.async {
                    // Update the weatherData state with fetched data
                    weatherData = WeatherData(locationName: weatherResponse.name, temperature: weatherResponse.main.temp, condition: weatherResponse.weather.first?.description ?? "")
                }
            } catch {
                print(error.localizedDescription)
            }
        }.resume()
    }
}

struct WeatherView_Previews: PreviewProvider {
    static var previews: some View {
        let previewBinding = Binding.constant("PreviewUserID")
        return WeatherView(userID: previewBinding)
    }
}


