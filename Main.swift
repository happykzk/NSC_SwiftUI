import SwiftUI
import AVFoundation
import MapKit
import Combine

extension Color {
    static let gold = Color(red: 255/255, green: 215/255, blue: 0/255)
}

// MARK: - SG60 Event Model
struct SG60Event: Identifiable {
    var id = UUID()
    var date: String
    var title: String
    var description: String
    var imageName: String
    var backgroundColor: Color
    var extraDetails: String
    var coordinate: CLLocationCoordinate2D
}

// MARK: - Music Player
class MusicPlayer {
    static let shared = MusicPlayer()
    var player: AVAudioPlayer?
    func playBackgroundMusic() {
        guard let url = Bundle.main.url(forResource: "background", withExtension: "mp3") else { return }
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.numberOfLoops = -1
            player?.play()
        } catch {
            print("Error playing music: \(error)")
        }
    }
}

// MARK: - Main App Entry Point
@main
struct SG60FinalApp: App {
    @AppStorage("darkMode") private var darkMode = false
    init() {
        MusicPlayer.shared.playBackgroundMusic()
    }
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .accentColor(.yellow)
                .preferredColorScheme(darkMode ? .dark : .light) // Toggle dark mode
        }
    }
}

// MARK: - Main Tab View
struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            NavigationView {
                TimelineView(events: SG60TimelineData.sampleEvents)
            }
            .tabItem {
                Label("Timeline", systemImage: "clock")
            }
            QuizView()
                .tabItem {
                    Label("Quiz", systemImage: "brain.head.profile")
                }
            SGMapView(events: SG60TimelineData.sampleEvents)
                .tabItem {
                    Label("Map", systemImage: "map")
                }
                .transition(.move(edge: .trailing))
            SettingsView() // New Settings page
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}

// MARK: - Home View
struct HomeView: View {
    @State private var showLogoAnimation = false
    @State private var currentFactIndex = 0
    let funFacts = [
        "Singapore has 64 offshore islands.",
        "The national language is Malay.",
        "The world's first night zoo is in Singapore.",
        "Singapore is one of the greenest cities in the world!",
        "The theme of SG60 is 'Building Our Singapore Together'.",
        "The first MRT station in Singapore was opened in 1983.",
        "The tallest building in Singapore is the Marina Bay Sands.",
        "The first skyscraper in Singapore was completed in 1990.",
        "Lions are the national animal of Singapore.",
        "The first IKEA store in Singapore was opened in 1992.",
        "The first Starbucks store in Singapore was opened in 1995.",
        "The first NUS (National University of Singapore) campus was opened in 1963.",
        "The first Changi Airport terminal was opened in 1981",
        "Dhoby Ghaut is the oldest residential area in Singapore.",
        "The first Marina Bay Sands was completed in 2001.",
        "Every year, Singapore hosts the World Expo to celebrate its achievements.",
        "'Satay' is also know as Sate! Satay is also a popular street food in Singapore.",
        "Aligators are also found in Singapore!",
        "Singapore is a melting pot of cultures!",
        "Singapore is known for its clean and safe environment!",
        "Singapore is a very safe city!",
        "Singapore also has a very rich history!",
        "Searching for something? Use the hyperlinks below to find out more!",
        "Tell your friends about this app!",
        "Who even reads this? 😅",
        "I hope you enjoyed this app!",
        "Sungei Buloh Wetland Reserve is know for its bird watching opporutnities.",
        "If you have any suggestions or feedback, please let me know!",
        "Sigma.",
        "Thanks for using this app! 😊",
        "Did you know that Singapore was originally called 'Temasek'?",
        "Have a great day! 🌞",
        "Womp womp.",
        "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
        "Singapore was originally a british colony.",
        "Technically, Singapore is not a country, but a city-state!",
        "The second Changi Airport terminal was opened in 1990."
    ]
    
    @AppStorage("fontSize") private var fontSize: Double = 14.0 // Font size from Settings
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [.blue, .purple]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            VStack(spacing: 20) {
                Image("sglogo")
                    .resizable()
                    .frame(width: 120, height: 120)
                    .clipShape(Circle())
                    .shadow(radius: 10)
                    .scaleEffect(showLogoAnimation ? 1.2 : 1)
                    .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: showLogoAnimation)
                Text("Welcome to SG60")
                    .font(.system(size: CGFloat(fontSize * 1.5)).bold()) // Adjusted for font size
                    .foregroundColor(.white)
                Text(funFacts[currentFactIndex])
                    .font(.system(size: CGFloat(fontSize))) // Adjusted for font size
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white.opacity(0.8))
                    .padding()
                    .onAppear {
                        Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { _ in
                            currentFactIndex = (currentFactIndex + 1) % funFacts.count
                        }
                    }
                
                // Adding Links to other resources on the Home Page
                VStack(spacing: 10) {
                    Link("Learn more about Singapore's History", destination: URL(string: "https://en.wikipedia.org/wiki/History_of_Singapore")!)
                        .foregroundColor(.white)
                        .font(.system(size: CGFloat(fontSize)))
                    
                    Link("Explore Singapore's Famous Landmarks", destination: URL(string: "https://www.celebritycruises.com/blog/landmarks-in-singapore")!)
                        .foregroundColor(.white)
                        .font(.system(size: CGFloat(fontSize)))
                    
                    Link("Check out the Singapore Tourism Board", destination: URL(string: "https://www.stb.gov.sg/")!)
                        .foregroundColor(.white)
                        .font(.system(size: CGFloat(fontSize)))
                }
                .padding(.top, 20)
            }
        }
        .onAppear {
            showLogoAnimation = true
        }
    }
}
// MARK: - Timeline View
struct TimelineView: View {
    let events: [SG60Event]
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                ForEach(events) { event in
                    NavigationLink(destination: EventDetailView(event: event)) {
                        EventCardView(event: event)
                    }
                }
            }
            .padding()
            .background(LinearGradient(gradient: Gradient(colors: [.green, .blue]), startPoint: .top, endPoint: .bottom))
            .cornerRadius(15)
            .shadow(radius: 10)
            .zIndex(-1)
        }
    }
}

// MARK: - Event Card View
struct EventCardView: View {
    var event: SG60Event
    @AppStorage("fontSize") private var fontSize: Double = 14.0 // Font size from Settings
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(event.date)
                .font(.system(size: CGFloat(fontSize)))
                .foregroundColor(.white)
                .padding(5)
                .background(event.backgroundColor)
                .cornerRadius(10)
            Image(event.imageName)
                .resizable()
                .scaledToFit()
                .frame(height: 150)
                .clipShape(RoundedRectangle(cornerRadius: 15))
            Text(event.title)
                .font(.system(size: CGFloat(fontSize * 1.2))).bold()
                .foregroundColor(event.backgroundColor)
            Text(event.description)
                .font(.system(size: CGFloat(fontSize))) // Adjusted for font size
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 10)
        .padding(.bottom, 10)
        .transition(.scale)
    }
}

// MARK: - Event Detail View
struct EventDetailView: View {
    var event: SG60Event
    @AppStorage("fontSize") private var fontSize: Double = 14.0 // Font size from Settings
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Image(event.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                Text(event.title)
                    .font(.system(size: CGFloat(fontSize * 1.5)).bold()) // Adjusted for font size
                    .foregroundColor(event.backgroundColor)
                Text(event.date)
                    .font(.system(size: CGFloat(fontSize))) // Adjusted for font size
                    .foregroundColor(.secondary)
                Text(event.extraDetails)
                    .font(.system(size: CGFloat(fontSize))) // Adjusted for font size
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
            }
            .padding()
        }
        .navigationTitle("Event Details")
    }
}

struct QuizView: View {
    @State private var currentQuestionIndex = 0
    @State private var score = 0
    @State private var showResult = false
    @State private var finalMessage = ""
    @State private var quizCompleted = false
    @State private var progress: Double = 0
    @State private var timeRemaining: Int = 0
    @State private var timer: AnyCancellable?
    @State private var timerStarted = false // Prevent multiple timers from starting
    
    @AppStorage("timerEnabled") private var timerEnabled = true
    @AppStorage("quizTimer") private var quizTimer: Double = 60.0 // Default 60 seconds
    
    let questions: [(question: String, options: [String], answer: String)] = [
            ("When did Singapore gain independence?", ["1963", "1965", "1987", "2000"], "1965"),
            ("What is the national flower of Singapore?", ["Rose", "Orchid", "Tulip", "Lily"], "Orchid"),
            ("Which MRT line was first launched?", ["Circle Line", "Downtown Line", "North-South Line", "East-West Line"], "North-South Line"),
            ("What year was the Marina Bay Sands completed?", ["2005", "2007", "2010", "2012"], "2010"),
            ("Who was the first Prime Minister of Singapore?", ["Lee Kuan Yew", "Goh Chok Tong", "Halimah Yacob", "Tan Chye Cheng"], "Lee Kuan Yew"),
            ("What is the name of Singapore's airport?", ["Changi Airport", "Paya Lebar Airport", "Seletar Airport", "Jurong Airport"], "Changi Airport"),
            ("Which building is known as the 'Durian' in Singapore?", ["Esplanade", "Marina Bay Sands", "Singapore Flyer", "Gardens by the Bay"], "Esplanade"),
            ("In what year did Singapore host the first Youth Olympic Games?", ["2008", "2010", "2012", "2014"], "2010"),
            ("What is Singapore's most famous dish?", ["Nasi Lemak", "Laksa", "Chilli Crab", "Hainanese Chicken Rice"], "Hainanese Chicken Rice"),
            ("Which country is Singapore's largest trading partner?", ["United States", "China", "Malaysia", "Japan"], "China"),
            ("What was Singapore's original name when it was founded?", ["Singapore", "Temasek", "Raffles City", "Pulau Ujong"], "Temasek"),
            ("Which iconic Singapore structure was built for the 2012 Singapore Art Show?", ["ArtScience Museum", "Marina Bay Sands", "Raffles Hotel", "National Gallery"], "ArtScience Museum"),
            ("Which famous Singaporean dish is also known as 'Sate'?", ["Satay", "Hainanese Chicken Rice", "Laksa", "Char Kway Teow"], "Satay"),
            ("Who is known as the 'Father of Singapore'?", ["Goh Chok Tong", "Lee Kuan Yew", "Halimah Yacob", "Tan Chye Cheng"], "Lee Kuan Yew"),
            ("What is the official language of Singapore?", ["English", "Malay", "Mandarin", "Tamil"], "Malay"),
            ("What year did Singapore celebrate its 50th anniversary of independence?", ["2015", "2010", "2020", "2005"], "2015"),
            ("Which significant political event took place in Singapore in 1965?", ["Independence from Malaysia", "Formation of Singapore Airlines", "The founding of the PAP", "Opening of the first MRT line"], "Independence from Malaysia"),
            ("What is the tallest building in Singapore?", ["Tanjong Pagar Centre", "Marina Bay Sands", "One Raffles Place", "The Pinnacle@Duxton"], "Tanjong Pagar Centre"),
            ("Which park in Singapore is home to over 5,000 species of plants?", ["Singapore Botanic Gardens", "Gardens by the Bay", "MacRitchie Reservoir", "East Coast Park"], "Singapore Botanic Gardens"),
            ("What year did Singapore establish the Singapore Armed Forces (SAF)?", ["1965", "1959", "1963", "1970"], "1965"),
            ("Which national monument in Singapore is located on the Singapore River and is a symbol of Singapore's history?", ["The Merlion", "Raffles Hotel", "Singapore Flyer", "Marina Bay Sands"], "The Merlion"),
            ("What year was the Singapore Flyer, one of the world’s largest observation wheels, completed?", ["2008", "2010", "2015", "2012"], "2008"),
            ("Which iconic bridge in Singapore is known for its unique design that is inspired by the shape of a dragon?", ["Henderson Waves", "Esplanade Bridge", "Cavenagh Bridge", "Alkaff Bridge"], "Henderson Waves"),
            ("In 2002, Singapore opened a world-class casino resort. What is its name?", ["Resorts World Sentosa", "Marina Bay Sands", "The Casino@Resorts World", "Singapore Marina"], "Resorts World Sentosa"),
            ("What year did Singapore establish its first national library?", ["1845", "1900", "1960", "1990"], "1845"),
            ("What is Singapore’s largest ethnic group?", ["Chinese", "Malay", "Indian", "Eurasian"], "Chinese"),
            ("What is the name of Singapore's first-ever mass rapid transit system?", ["North-South Line", "Circle Line", "Downtown Line", "Thomson-East Coast Line"], "North-South Line"),
            ("Which famous statue in Singapore was created to represent the nation's strength and resilience?", ["The Merlion", "Statue of Raffles", "The Dragon Fountain", "The Lion Head"], "The Merlion"),
            ("What year did Singapore become a member of the United Nations?", ["1965", "1970", "1980", "1990"], "1965"),
            ("Which is Singapore's largest shopping street?", ["Orchard Road", "Bugis Street", "Haji Lane", "Chinatown"], "Orchard Road"),
            ("What is the name of Singapore's iconic tropical garden, which is a UNESCO World Heritage Site?", ["Singapore Botanic Gardens", "Gardens by the Bay", "Jurong Bird Park", "MacRitchie Reservoir"], "Singapore Botanic Gardens"),
            ("Which year did Singapore host the Asia Pacific Economic Cooperation (APEC) Summit?", ["2009", "2015", "2001", "2012"], "2009"),
            ("Which famous building in Singapore was the tallest building in the country when it was completed in 1976?", ["The OUB Centre", "The Straits Trading Building", "The UOB Building", "Marina Bay Sands"], "The OUB Centre"),
            ("What is the name of Singapore's leading international business and finance district?", ["Raffles Place", "Marina Bay", "Chinatown", "Tanjong Pagar"], "Raffles Place"),
            ("Which Singaporean landmark was declared a UNESCO World Heritage Site in 2017?", ["Kampong Glam", "Singapore Botanic Gardens", "Chinatown", "Marina Bay Sands"], "Kampong Glam"),
            ("What year was the Singapore Management University (SMU) established?", ["2000", "1995", "1985", "2010"], "2000"),
            ("In which year did Singapore introduce its first local currency notes after independence?", ["1967", "1975", "1965", "1980"], "1967"),
            ("What is the name of Singapore's first public housing estate?", ["Tiong Bahru", "Queenstown", "Bukit Merah", "Toa Payoh"], "Tiong Bahru"),
            ("Who was the first female President of Singapore?", ["Halimah Yacob", "Tony Tan", "S. R. Nathan", "Benjamin Sheares"], "Halimah Yacob"),
            ("Which year did Singapore host the Southeast Asian Games?", ["2015", "2010", "2005", "2002"], "2015")
            ]

    func calculateFinalMessage() {
        if score == questions.count {
            finalMessage = "Excellent! Perfect Score!"
        } else if score >= questions.count / 2 {
            finalMessage = "Great job! You're on fire!"
        } else {
            finalMessage = "Good try! Keep learning!"
        }
    }
    
    func restartQuiz() {
        currentQuestionIndex = 0
        score = 0
        showResult = false
        finalMessage = ""
        quizCompleted = false
        progress = 0
        timeRemaining = Int(quizTimer) // Reset timer to initial value
    }
    
    func startTimer() {
        if timerEnabled && !timerStarted {
            timerStarted = true // Prevent restarting the timer multiple times
            
            timer = Timer.publish(every: 1, on: .main, in: .common)
                .autoconnect()
                .sink { _ in
                    if timeRemaining > 0 {
                        timeRemaining -= 1
                    } else {
                        // Timer reaches zero, end the quiz
                        timer?.cancel()
                        calculateFinalMessage()
                        quizCompleted = true
                        showResult = true
                    }
                }
        }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("SG60 Quiz")
                .font(.largeTitle.bold())
            
            if quizCompleted {
                Text("Your final score: \(score)/\(questions.count)")
                    .font(.headline)
                    .padding()
                Text(finalMessage)
                    .font(.title2)
                    .bold()
                    .foregroundColor(.green)
                    .padding()
                Button(action: restartQuiz) {
                    Text("Restart Quiz")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
            } else {
                // Timer display
                if timerEnabled {
                    TimerView(timerValue: $timeRemaining)
                }
                
                Text(questions[currentQuestionIndex].question)
                    .font(.title2)
                    .padding()
                
                ForEach(questions[currentQuestionIndex].options, id: \.self) { option in
                    Button(action: {
                        if option == questions[currentQuestionIndex].answer {
                            score += 1
                        }
                        if currentQuestionIndex < questions.count - 1 {
                            currentQuestionIndex += 1
                            progress = Double(currentQuestionIndex) / Double(questions.count)
                        } else {
                            calculateFinalMessage()
                            quizCompleted = true
                            showResult = true
                        }
                    }) {
                        Text(option)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue.opacity(1))
                            .cornerRadius(10)
                            .padding(5)
                            .disabled(quizCompleted)
                    }
                }
                
                ProgressBar(value: progress) // Progress Bar
            }
        }
        .onAppear {
            // Initialize timeRemaining with the quizTimer value from settings
            timeRemaining = Int(quizTimer)
            startTimer()
        }
        .padding()
    }
}

// Timer View (Displays time remaining)
struct TimerView: View {
    @Binding var timerValue: Int
    
    var body: some View {
        HStack {
            Text("Time Left: \(timerValue)s")
                .font(.system(size: 18))
                .foregroundColor(.red)
        }
    }
}

// MARK: - Progress Bar View
struct ProgressBar: View {
    var value: Double
    var body: some View {
        VStack {
            Text("Progress: \(Int(value * 100))%")
                .foregroundColor(.gray)
            ProgressView(value: value, total: 1.0)
                .progressViewStyle(LinearProgressViewStyle())
                .padding()
        }
    }
}
// MARK: - Map View with Zoom and Reset
struct SGMapView: View {
    let events: [SG60Event]
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 1.3521, longitude: 103.8198),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    
    private let minZoom: CLLocationDegrees = 0.002
    private let maxZoom: CLLocationDegrees = 10.0
    
    func zoomIn() {
        let newLatitudeDelta = max(region.span.latitudeDelta / 2, minZoom)
        let newLongitudeDelta = max(region.span.longitudeDelta / 2, minZoom)
        region.span = MKCoordinateSpan(latitudeDelta: newLatitudeDelta, longitudeDelta: newLongitudeDelta)
    }
    
    func zoomOut() {
        let newLatitudeDelta = min(region.span.latitudeDelta * 2, maxZoom)
        let newLongitudeDelta = min(region.span.longitudeDelta * 2, maxZoom)
        region.span = MKCoordinateSpan(latitudeDelta: newLatitudeDelta, longitudeDelta: newLongitudeDelta)
    }
    
    func resetMap() {
        region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 1.3521, longitude: 103.8198),
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        )
    }
    
    var body: some View {
        VStack {
            Map(coordinateRegion: $region, annotationItems: events) { event in
                MapMarker(coordinate: event.coordinate, tint: event.backgroundColor)
            }
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.blue, lineWidth: 4)
            )
            .padding()
            
            HStack {
                Button("Zoom In") { zoomIn() }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                
                Button("Zoom Out") { zoomOut() }
                    .padding()
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                
                Button("Reset Map") { resetMap() }
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
        }
    }
}

// MARK: - Settings View
struct SettingsView: View {
    @AppStorage("darkMode") private var darkMode = false
    @AppStorage("fontSize") private var fontSize: Double = 14.0
    @AppStorage("timerEnabled") private var timerEnabled = true
    @AppStorage("quizTimer") private var quizTimer: Double = 60.0 // Default 60 seconds
    var body: some View {
        NavigationView {
            List {
                // Dark Mode Section
                Section(header: Text("Appearance").font(.headline)) {
                    Toggle(isOn: $darkMode) {
                        HStack {
                            Image(systemName: "moon.fill")
                            Text("Dark Mode")
                        }
                    }
                    .toggleStyle(SwitchToggleStyle(tint: .blue))
                }
                // Font Size Section
                Section(header: Text("Font Size").font(.headline)) {
                    VStack {
                        HStack {
                            Image(systemName: "textformat.size")
                            Text("Adjust Font Size")
                            Spacer()
                            Text("\(Int(fontSize)) pt")
                                .foregroundColor(.gray)
                        }
                        Slider(value: $fontSize, in: 12...24, step: 1)
                            .accentColor(.blue)
                    }
                }
                // Timer Section
                Section(header: Text("Quiz Settings").font(.headline)) {
                    Toggle(isOn: $timerEnabled) {
                        HStack {
                            Image(systemName: "clock.fill")
                            Text("Enable Timer")
                        }
                    }
                    .toggleStyle(SwitchToggleStyle(tint: .blue))
                    if timerEnabled {
                        VStack {
                            HStack {
                                Image(systemName: "timer")
                                Text("Quiz Timer")
                                Spacer()
                                Text("\(Int(quizTimer)) sec")
                                    .foregroundColor(.gray)
                            }
                            Slider(value: $quizTimer, in: 30...300, step: 10)
                                .accentColor(.blue)
                        }
                    }
                }
                // Reset Settings Section
                Section {
                    Button(action: resetSettings) {
                        HStack {
                            Image(systemName: "arrow.uturn.backward.circle.fill")
                            Text("Reset Settings")
                                .foregroundColor(.red)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .navigationTitle("Settings")
            .listStyle(GroupedListStyle()) // Make the settings look grouped like Apple's style
        }
    }
    // Reset Settings Action
    private func resetSettings() {
        darkMode = false
        fontSize = 14.0
        timerEnabled = true
        quizTimer = 60.0
    }
}
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .preferredColorScheme(.light) // Adjust for light/dark mode
    }
}
// MARK: - SG60 Timeline Data
struct SG60TimelineData {
    static let sampleEvents: [SG60Event] = [
        SG60Event(
            date: "1965",
            title: "Independence",
            description: "Singapore became an independent republic.",
            imageName: "IndependenceImage",
            backgroundColor: .blue,
            extraDetails: """
                On 9 August 1965, Singapore separated from Malaysia and became an independent nation under the leadership of Lee Kuan Yew. This event marked a new chapter in Singapore's history as a self-governed republic. The independence declaration came after Malaysia's Parliament passed the Singapore Separation Bill, following a series of political crises. Singapore’s independence was followed by years of rapid economic growth and urban development. This marked the beginning of a unique path for Singapore, which transformed from a small port city into a global financial and economic hub.
            """,
            coordinate: CLLocationCoordinate2D(latitude: 1.2966, longitude: 103.7764)
        ),
        SG60Event(
            date: "1967",
            title: "ASEAN Founding",
            description: "Singapore was a founding member of ASEAN.",
            imageName: "aseanFoundingImage",
            backgroundColor: .orange,
            extraDetails: """
                In 1967, Singapore, along with Indonesia, Malaysia, the Philippines, Thailand, and Brunei, founded the Association of Southeast Asian Nations (ASEAN). This regional organization was created to promote economic, political, and security cooperation among Southeast Asian countries. ASEAN has played a critical role in maintaining peace and fostering development in the region, and Singapore has been a key advocate of regional integration and cooperation throughout its history.
            """,
            coordinate: CLLocationCoordinate2D(latitude: 1.3521, longitude: 103.8198)
        ),
        SG60Event(
            date: "1971",
            title: "Withdrawal of British Forces",
            description: "The British military withdrew from Singapore.",
            imageName: "britishForcesWithdrawalImage",
            backgroundColor: .brown,
            extraDetails: """
                In 1971, the British military completed its withdrawal from Singapore, marking the end of Singapore's strategic dependence on the British Empire for defense. The event was a significant turning point, as Singapore had to establish its own defense policies and military capabilities. The Singapore Armed Forces (SAF) became an important pillar of national security, and the country took steps towards a self-reliant defense strategy.
            """,
            coordinate: CLLocationCoordinate2D(latitude: 1.2966, longitude: 103.7764)
        ),
        SG60Event(
            date: "1981",
            title: "Changi Airport Opens",
            description: "Singapore's world-class airport, Changi, opened its doors.",
            imageName: "changiAirportImage",
            backgroundColor: .green,
            extraDetails: """
                In 1981, Changi Airport was officially opened, rapidly becoming one of the world’s best airports. Renowned for its efficiency, exceptional customer service, and unique attractions, Changi Airport has become a global hub and a symbol of Singapore’s commitment to providing world-class services in aviation.
            """,
            coordinate: CLLocationCoordinate2D(latitude: 1.3644, longitude: 103.9915)
        ),
        SG60Event(
            date: "1990",
            title: "The First ERP System",
            description: "Singapore introduced the first Electronic Road Pricing (ERP) system.",
            imageName: "erpSystemImage",
            backgroundColor: .green,
            extraDetails: """
                In 1990, Singapore became the first city in the world to implement an Electronic Road Pricing (ERP) system. The ERP was introduced to manage road congestion and improve traffic flow. This initiative was a breakthrough in urban traffic management and set the stage for similar smart transportation solutions worldwide.
            """,
            coordinate: CLLocationCoordinate2D(latitude: 1.3521, longitude: 103.8198)
        ),
        SG60Event(
            date: "1997",
            title: "Asian Financial Crisis",
            description: "Singapore faced economic challenges during the financial crisis.",
            imageName: "asianCrisisImage",
            backgroundColor: .red,
            extraDetails: """
                The Asian Financial Crisis of 1997-1998 impacted many Southeast Asian economies, including Singapore. The crisis led to a severe recession, devaluation of regional currencies, and stock market crashes. Despite this, Singapore managed to weather the storm with prudent economic policies and strategic economic diversification, which helped it bounce back quickly and emerge stronger.
            """,
            coordinate: CLLocationCoordinate2D(latitude: 1.3521, longitude: 103.8198)
        ),
        SG60Event(
            date: "1999",
            title: "Singapore Science Park",
            description: "Singapore Science Park was established to foster technology and innovation.",
            imageName: "scienceParkImage",
            backgroundColor: .purple,
            extraDetails: """
                In 1999, Singapore opened the Singapore Science Park, a key initiative to promote technology and innovation. The park became a focal point for high-tech industries and research, helping position Singapore as a global leader in technology development and advanced industries.
            """,
            coordinate: CLLocationCoordinate2D(latitude: 1.3249, longitude: 103.7572)
        ),
        SG60Event(
            date: "2000",
            title: "Singapore Exchange (SGX) Merger",
            description: "Singapore Stock Exchange merged with the Stock Exchange of Singapore.",
            imageName: "sgxMergerImage",
            backgroundColor: .teal,
            extraDetails: """
                In 2000, the Singapore Stock Exchange (SGX) merged with the Stock Exchange of Singapore to form a fully integrated exchange offering a complete range of securities trading services. This move strengthened Singapore's position as a global financial hub and enhanced the country's competitiveness in the global market.
            """,
            coordinate: CLLocationCoordinate2D(latitude: 1.2822, longitude: 103.8498)
        ),
        SG60Event(
            date: "2003",
            title: "SARS Outbreak",
            description: "Singapore effectively contained the SARS epidemic.",
            imageName: "sarsOutbreakImage",
            backgroundColor: .yellow,
            extraDetails: """
                In 2003, Singapore faced the global outbreak of Severe Acute Respiratory Syndrome (SARS). Despite its early stages of the outbreak, Singapore implemented strict public health measures, including contact tracing, quarantine, and travel restrictions, which helped contain the spread of the virus. This response demonstrated Singapore's strong public health infrastructure and crisis management capabilities.
            """,
            coordinate: CLLocationCoordinate2D(latitude: 1.3521, longitude: 103.8198)
        ),
        SG60Event(
            date: "2005",
            title: "Singapore Sports Hub Announcement",
            description: "The Singapore Sports Hub, a multi-purpose sports facility, was announced.",
            imageName: "sportsHubAnnouncementImage",
            backgroundColor: .red,
            extraDetails: """
                In 2005, Singapore announced the development of the Singapore Sports Hub, a major project to bring together world-class sporting venues under one roof. The hub would become a major asset for both international sporting events and local recreation, solidifying Singapore's position as a global sports destination.
            """,
            coordinate: CLLocationCoordinate2D(latitude: 1.2966, longitude: 103.7764)
        ),
        SG60Event(
            date: "2008",
            title: "Singapore Flyer",
            description: "The Singapore Flyer, the world’s largest observation wheel, was completed.",
            imageName: "singaporeFlyerImage",
            backgroundColor: .purple,
            extraDetails: """
                In 2008, Singapore opened the Singapore Flyer, a giant observation wheel that stands at 165 meters tall. The Flyer became an iconic landmark offering breathtaking views of the city, Marina Bay, and beyond. It has become one of the most popular tourist attractions in Singapore, contributing to the city’s status as a major global destination for tourism and leisure.
            """,
            coordinate: CLLocationCoordinate2D(latitude: 1.2890, longitude: 103.8647)
        ),
        SG60Event(
            date: "2010",
            title: "Youth Olympic Games",
            description: "Singapore hosted the inaugural Youth Olympic Games.",
            imageName: "youthOlympicsImage",
            backgroundColor: .cyan,
            extraDetails: """
                In 2010, Singapore became the first Asian country to host the Youth Olympic Games (YOG), an international multi-sport event for young athletes aged 14-18. The event was a significant milestone in promoting youth sports, cultural exchange, and global friendship. The success of the event boosted Singapore's international profile as a center for major global sporting events.
            """,
            coordinate: CLLocationCoordinate2D(latitude: 1.2833, longitude: 103.8607)
        ),
        SG60Event(
            date: "2015",
            title: "SG50 Celebrations",
            description: "Singapore celebrated its 50th anniversary of independence.",
            imageName: "sg50CelebrationsImage",
            backgroundColor: .gold,
            extraDetails: """
                In 2015, Singapore celebrated SG50, marking 50 years since the country’s independence. The celebrations included national events, parades, and a series of cultural activities, showcasing the achievements and progress made since Singapore’s independence. The SG50 celebrations brought together Singaporeans of all ages to reflect on their shared journey and envision the future.
            """,
            coordinate: CLLocationCoordinate2D(latitude: 1.3521, longitude: 103.8198)
        ),
        SG60Event(
            date: "2020",
            title: "Singapore Green Plan 2030",
            description: "Singapore launched its Green Plan to fight climate change.",
            imageName: "greenPlanImage",
            backgroundColor: .green,
            extraDetails: """
                In 2020, Singapore launched its Green Plan 2030, aimed at transforming the country into a leading hub for sustainable development. The plan focuses on improving sustainability, reducing carbon emissions, and integrating green technology into daily life. It reflects Singapore's commitment to environmental responsibility and its proactive stance in addressing climate change.
            """,
            coordinate: CLLocationCoordinate2D(latitude: 1.3521, longitude: 103.8198)
        ),
        SG60Event(
            date: "2021",
            title: "COVID-19 Response",
            description: "Singapore responded effectively to the global pandemic.",
            imageName: "covid19Image",
            backgroundColor: .gray,
            extraDetails: """
                In 2021, Singapore was praised globally for its effective response to the COVID-19 pandemic. The country's robust healthcare system, early implementation of strict public health measures, and rapid vaccine rollout helped contain the virus and protect its citizens. Despite facing challenges, Singapore's response showcased its resilience and the importance of strong governance in managing public health crises.
            """,
            coordinate: CLLocationCoordinate2D(latitude: 1.3521, longitude: 103.8198)
        ),
        SG60Event(
            date: "2025",
            title: "Launch of the Singapore Green Building Council",
            description: "Singapore established the Green Building Council to promote sustainability.",
            imageName: "greenBuildingCouncilImage",
            backgroundColor: .green,
            extraDetails: """
                In 2025, Singapore officially launched the Singapore Green Building Council (SGBC) to promote green building practices. This was a key step in advancing sustainability efforts across industries, particularly in urban planning and construction, helping to set a global standard for sustainable cities.
            """,
            coordinate: CLLocationCoordinate2D(latitude: 1.3521, longitude: 103.8198)
        ),
    ]
}

