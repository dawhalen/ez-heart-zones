import SwiftUI

struct ContentView: View {
    @StateObject private var healthKitManager = HealthKitManager()

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("EZ Heart Zones")
                    .font(.largeTitle)
                    .bold()

                Button("Request Health Access") {
                    Task {
                        await healthKitManager.requestAuthorization()
                    }
                }
                .buttonStyle(.borderedProminent)

                Text(healthKitManager.authorizationStatusDescription)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .navigationTitle("Home")
        }
    }
}

#Preview {
    ContentView()
}
