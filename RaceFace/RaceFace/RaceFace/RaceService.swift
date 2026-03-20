import Foundation

struct RaceResponse: Codable {
    let MRData: MRData
}

struct MRData: Codable {
    let RaceTable: RaceTable
}

struct RaceTable: Codable {
    let Races: [Race]
}

struct Race: Codable {
    let raceName: String
    let date: String
    let time: String?
    
    let FirstPractice: Session?
    let SecondPractice: Session?
    let ThirdPractice: Session?
    let Qualifying: Session?
    
    let Sprint: Session?
    let SprintQualifying: Session? // ✅ NEW
}

struct Session: Codable {
    let date: String
    let time: String
}

class RaceService {
    
    static func fetchNextRace(completion: @escaping (Race?) -> Void) {
        
        let url = URL(string: "https://api.jolpi.ca/ergast/f1/current.json")!
        
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data else { return }
            
            do {
                let decoded = try JSONDecoder().decode(RaceResponse.self, from: data)
                
                let formatter = ISO8601DateFormatter()
                let now = Date()
                
                for race in decoded.MRData.RaceTable.Races {
                    let full = race.date + "T" + (race.time ?? "00:00:00Z")
                    
                    if let raceDate = formatter.date(from: full),
                       raceDate > now {
                        completion(race)
                        return
                    }
                }
                
                completion(decoded.MRData.RaceTable.Races.last)
                
            } catch {
                print("Decode error:", error)
            }
        }.resume()
    }
}
