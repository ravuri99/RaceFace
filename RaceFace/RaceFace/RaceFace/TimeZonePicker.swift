import SwiftUI

struct TimeZonePicker: View {
    
    @Binding var selectedTimeZone: TimeZone
    
    let timeZones = TimeZone.knownTimeZoneIdentifiers
    
    var body: some View {
        NavigationView {
            List(timeZones, id: \.self) { tz in
                Button {
                    selectedTimeZone = TimeZone(identifier: tz) ?? .current
                } label: {
                    HStack {
                        Text(tz)
                        Spacer()
                        if selectedTimeZone.identifier == tz {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
            .navigationTitle("Select Timezone")
        }
    }
}
