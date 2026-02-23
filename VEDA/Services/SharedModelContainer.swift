import SwiftData
import Foundation

func sharedModelConfiguration() -> ModelConfiguration {
    let appGroupID = "group.app.vercel.johnnylau.VEDA"
    guard let containerURL = FileManager.default
        .containerURL(forSecurityApplicationGroupIdentifier: appGroupID) else {
        return ModelConfiguration(
            schema: Schema([Task.self, Chore.self, SleepEntry.self]),
            isStoredInMemoryOnly: false
        )
    }
    let storeURL = containerURL.appendingPathComponent("VEDA.sqlite")
    return ModelConfiguration(
        schema: Schema([Task.self, Chore.self, SleepEntry.self]),
        url: storeURL
    )
}
