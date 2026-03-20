import SwiftUI

struct SessionRow: View {
    let name: String
    let time: String
    let date: Date?

    var body: some View {
        HStack(spacing: 12) {

            VStack {
                Text(day())
                    .font(.headline)
                    .foregroundColor(.white)

                Text(month())
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .frame(width: 40)

            Divider()
                .frame(height: 30)
                .background(Color.gray.opacity(0.3))

            Text(name.uppercased())
                .foregroundColor(.white)
                .fontWeight(.semibold)

            Spacer()

            Text(time)
                .foregroundColor(.white)
                .font(.system(.body, design: .monospaced))
        }
        .padding(.vertical, 6)
    }

    func day() -> String {
        guard let date else { return "--" }
        let f = DateFormatter()
        f.dateFormat = "dd"
        return f.string(from: date)
    }

    func month() -> String {
        guard let date else { return "--" }
        let f = DateFormatter()
        f.dateFormat = "MMM"
        return f.string(from: date).uppercased()
    }
}
