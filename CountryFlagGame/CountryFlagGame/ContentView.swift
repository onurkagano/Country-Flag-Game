//
//  ContentView.swift
//  CountryFlagGame
//
//  Created by onurkagano on 19.01.2024.
//

import SwiftUI
import Modals

extension Color {
    
    init(hex: String) {
            let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
            var int: UInt64 = 0
            Scanner(string: hex).scanHexInt64(&int)
            let a, r, g, b: UInt64
            switch hex.count {
            case 3: // RGB (12-bit)
                (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
            case 6: // RGB (24-bit)
                (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
            case 8: // ARGB (32-bit)
                (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
            default:
                (a, r, g, b) = (1, 1, 1, 0)
            }

            self.init(
                .sRGB,
                red: Double(r) / 255,
                green: Double(g) / 255,
                blue:  Double(b) / 255,
                opacity: Double(a) / 255
            )
        }
}


struct ContentView: View {
    @State private var countries = ["Austria", "Andorra", "Albania", "Bulgaria", "Bosnia And Herzegovina", "Belgium", "Belarus", "Denmark", "Czech Republic", "Croatia", "Greece", "Germany", "Georgia", "France", "Finland", "Estonia", "Italy", "Ireland", "Iceland", "Hungary", "Macedonia", "Luxembourg", "Lithuania"].shuffled()
    
    @State private var countriesOnGame = ["Austria", "Andorra", "Albania", "Bulgaria", "Bosnia And Herzegovina", "Belgium", "Belarus", "Denmark", "Czech Republic", "Croatia", "Greece", "Germany", "Georgia", "France", "Finland", "Estonia", "Italy", "Ireland", "Iceland", "Hungary", "Macedonia", "Luxembourg", "Lithuania"].shuffled()
    
    
    @State private var remainingFlags = 23
    @State private var score = 0
    
    @State private var correctAnswer = Int.random(in: 0...3)
    @State private var wrongAnswer = false
    @State private var gameOver = false
    @State private var selectedAnswer = -1
        
    var body: some View {
        ZStack {
            RadialGradient(stops: [
                .init(color: Color(hex: "9b2226"), location: 0.3),
                .init(color: Color(hex: "0a9396"), location: 0.6)
            ], center: .top, startRadius: 100, endRadius: 500)
                .ignoresSafeArea()
            
            VStack (spacing:20){
                Spacer()
                VStack{
                    Text("Tap the flag of")
                        .foregroundStyle(.white)
                        .font(.subheadline.weight(.heavy))
                    
                    Text(countriesOnGame[correctAnswer])
                        .frame(width: 300)
                        .foregroundStyle(.white)
                        .font(.largeTitle.weight(.semibold))
                }
                Spacer()
                Text("Remaining \(Image(systemName: "flag.square.fill")): \(remainingFlags)")
                    .font(.largeTitle)
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(.rect(cornerRadius: 20))
                    .foregroundColor(.white)
                Spacer()
                HStack{
                    ForEach(0..<2) { number in
                        Button(action: {
                            flagTapped(number)
                        }, label: {
                            Image(countriesOnGame[number])
                                .resizable()
                                .frame(width: 150.0, height: 150.0)
                                .clipShape(.rect(cornerRadius: 20))
                                .padding()
                        })
                        
                        .background(.ultraThinMaterial)
                        .clipShape(.rect(cornerRadius: 30))
                        .transition(.opacity)
                    }
                                        
                }
                HStack{
                    ForEach(2..<4) { number in
                        Button(action: {
                            flagTapped(number)
                        }, label: {
                            Image(countriesOnGame[number])
                                .resizable()
                                .frame(width: 150.0, height: 150.0)
                                .clipShape(.rect(cornerRadius: 20))
                                .padding()
                        })
                        
                    }
                    .background(.ultraThinMaterial)
                    .clipShape(.rect(cornerRadius: 30))
                    .transition(.opacity)
                    
                }
                Spacer()
                    
                Text("Score: \(score)")
                    .font(.largeTitle)
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(.rect(cornerRadius: 20))
                    .foregroundColor(.white)
                Spacer()
         
            }
            .frame(maxWidth: .infinity)
            .padding(20)
        }
        .sheet(isPresented: $wrongAnswer, onDismiss: {
            askQuestion()
        }, content: {
            WrongAnswerView(correctCountry: countriesOnGame[correctAnswer])
                .presentationDetents([.fraction(0.4)])
        })
        
        .sheet(isPresented: $gameOver, onDismiss: {
            countriesOnGame = countries
            remainingFlags = 23
            score = 0
            askQuestion()
        }, content: {
            GameOverView(finalScore: score)
                .presentationDetents([.fraction(0.4)])
        })
    }
    
    func flagTapped(_ number: Int) {
        if number == correctAnswer {
            score += 1
            askQuestion()
            
        } else {
            wrongAnswer.toggle()
        }
        remainingFlags -= 1
    }
    
    func askQuestion() {
        if remainingFlags > 4 {
            if let indexToRemove = countriesOnGame.firstIndex(of: countriesOnGame[correctAnswer]) {
                countriesOnGame.remove(at: indexToRemove)
            }
            countriesOnGame.shuffle()
            correctAnswer = Int.random(in: 0...3)
        } else {
            gameOver = true
        }
    }
}

struct WrongAnswerView: View {
    let correctCountry: String
    
    var body: some View {
        ZStack{
            
            LinearGradient(stops: [
                .init(color: Color(hex: "9b2226"), location: 0.3),
                .init(color: Color(hex: "0a9396"), location: 0.6)
            ], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            VStack {
                Text("The correct answer for \(correctCountry) was:")
                    .font(.title2)
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(.rect(cornerRadius: 20))
                    .foregroundColor(.white)
                Image(correctCountry)
                    .resizable()
                    .clipShape(.rect(cornerRadius: 20))
                    .padding()
                    .background(.ultraThinMaterial)
                    .frame(width: 200, height: 200)
                    .clipShape(.rect(cornerRadius: 30))
                    
            }
        }
    }
}

struct GameOverView: View {
    let finalScore: Int
    
    var body: some View {
        ZStack{
            
            LinearGradient(stops: [
                .init(color: Color(hex: "9b2226"), location: 0.3),
                .init(color: Color(hex: "0a9396"), location: 0.6)
            ], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            VStack {
                Text("Your score was: \(finalScore)")
                    .font(.largeTitle)
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(.rect(cornerRadius: 20))
                    .foregroundColor(.white)
                Text("Close this to play again")
                    .font(.body)
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(.rect(cornerRadius: 20))
                    .foregroundColor(.white)
                
                    
            }
        }
    }
}


#Preview {
    ContentView()
}
