import SwiftUI

struct HomeView: View {
    
    @State private var nextRace = "Loading..."
    @State private var raceDate: Date = Date()
    @State private var now = Date()
    
    // Sessions
    @State private var fp1Date: Date?
    @State private var fp2Date: Date?
    @State private var fp3Date: Date?
    @State private var qualiDate: Date?
    @State private var sprintDate: Date?
    @State private var sprintQualiDate: Date?
    
    // Timezone
    @State private var selectedTimeZone: TimeZone = .current
    @State private var showPicker = false
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 20) {
                
                // 🌍 Timezone
                Button {
                    showPicker.toggle()
                } label: {
                    Text(selectedTimeZone.localizedName(for: .standard, locale: .current) ?? selectedTimeZone.identifier)
                        .foregroundColor(.gray)
                        .font(.caption)
                }
                .sheet(isPresented: $showPicker) {
                    TimeZonePicker(selectedTimeZone: $selectedTimeZone)
                }
                
                // 🔴 Circle UI
                // 🔴 NEW PREMIUM HEADER UI
                ZStack {

                    // Background glow
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color.red.opacity(0.25), Color.clear],
                                center: .center,
                                startRadius: 10,
                                endRadius: 180
                            )
                        )
                        .frame(width: 300, height: 300)

                    // Glass Card
                    RoundedRectangle(cornerRadius: 30)
                        .fill(Color.white.opacity(0.05))
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 30))
                        .overlay(
                            RoundedRectangle(cornerRadius: 30)
                                .stroke(Color.red.opacity(0.3), lineWidth: 1)
                        )
                        .frame(minHeight: 320)
                        .padding(.vertical, 10)

                    VStack(spacing: 16) {

                        // F1 Badge
                        Text("F1")
                            .font(.caption.bold())
                            .foregroundColor(.red)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.red.opacity(0.15))
                            .clipShape(Capsule())

                        // Race Name
                        Text(nextRace)
                            .font(.title3.weight(.semibold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)

                        // BIG Countdown Number
                        Text(daysRemaining())
                            .font(.system(size: 60, weight: .bold))
                            .foregroundStyle(
                                LinearGradient(colors: [.red, .pink], startPoint: .top, endPoint: .bottom)
                            )

                        Text("Days Remaining")
                            .foregroundColor(.gray)
                            .font(.caption)

                        // Timer
                        Text(fullCountdown())
                            .font(.system(.body, design: .monospaced))
                            .foregroundColor(.white)

                        Divider()
                            .background(Color.gray.opacity(0.3))
                            .padding(.horizontal, 30)

                        VStack(spacing: 4) {
                            Text("Race Time")
                                .font(.caption)
                                .foregroundColor(.gray)

                            Text(raceTimeInUserZone())
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                    }
                    .padding()
                }
                .padding(.horizontal)
                // 🏁 DYNAMIC SESSIONS (CORRECT LOGIC)
                VStack(alignment: .leading, spacing: 12) {

                    Text("Sessions")
                        .foregroundColor(.white)
                        .font(.headline)

                    if let fp1Date {
                        SessionRow(name: "FP1", time: formatSession(fp1Date), date: fp1Date)
                    }

                    if let fp2Date {
                        SessionRow(name: "FP2", time: formatSession(fp2Date), date: fp2Date)
                    }

                    // FP3 only if NO sprint
                    if sprintDate == nil, let fp3Date {
                        SessionRow(name: "FP3", time: formatSession(fp3Date), date: fp3Date)
                    }

                    // Sprint Qualifying
                    if let sprintQualiDate {
                        SessionRow(name: "Sprint Qualifying", time: formatSession(sprintQualiDate), date: sprintQualiDate)
                    }

                    // Sprint Race
                    if let sprintDate {
                        SessionRow(name: "Sprint", time: formatSession(sprintDate), date: sprintDate)
                    }

                    // Race Qualifying
                    if let qualiDate {
                        SessionRow(name: "Qualifying", time: formatSession(qualiDate), date: qualiDate)
                    }

                    // Race
                    SessionRow(name: "Race", time: raceTimeOnly(), date: raceDate)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.05))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.red.opacity(0.3), lineWidth: 1)
                        )
                )
                .padding(.horizontal)
                
                Spacer()
            }
            .padding()
        }
        .onAppear {
            fetchRace()
            startTimer()
        }
    }
}

// MARK: LOGIC
extension HomeView {
    
    func fetchRace() {
        RaceService.fetchNextRace { race in
            DispatchQueue.main.async {
                guard let race else { return }

                nextRace = race.raceName
                let f = ISO8601DateFormatter()

                raceDate = f.date(from: race.date + "T" + (race.time ?? "00:00:00Z")) ?? Date()

                if let s = race.FirstPractice {
                    fp1Date = f.date(from: s.date + "T" + s.time)
                }

                if let s = race.SecondPractice {
                    fp2Date = f.date(from: s.date + "T" + s.time)
                }

                if let s = race.ThirdPractice {
                    fp3Date = f.date(from: s.date + "T" + s.time)
                }

                if let s = race.Qualifying {
                    qualiDate = f.date(from: s.date + "T" + s.time)
                }

                if let s = race.Sprint {
                    sprintDate = f.date(from: s.date + "T" + s.time)
                }

                if let s = race.SprintQualifying {
                    sprintQualiDate = f.date(from: s.date + "T" + s.time)
                }
            }
        }
    }
    
    func startTimer() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            now = Date()
        }
    }
    
    func daysRemaining() -> String {
        let diff = max(0, Int(raceDate.timeIntervalSince(now)))
        return "\(diff / 86400)"
    }
    
    func fullCountdown() -> String {
        let diff = max(0, Int(raceDate.timeIntervalSince(now)))
        
        let d = diff / 86400
        let h = (diff % 86400) / 3600
        let m = (diff % 3600) / 60
        let s = diff % 60
        
        return String(format: "%02dd %02dh %02dm %02ds", d, h, m, s)
    }
    
    func raceTimeInUserZone() -> String {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        f.timeZone = selectedTimeZone
        return f.string(from: raceDate)
    }
    
    func raceTimeOnly() -> String {
        let f = DateFormatter()
        f.timeStyle = .short
        f.timeZone = selectedTimeZone
        return f.string(from: raceDate)
    }
    
    func formatSession(_ date: Date) -> String {
        let f = DateFormatter()
        f.timeStyle = .short
        f.timeZone = selectedTimeZone
        return f.string(from: date)
    }
}
