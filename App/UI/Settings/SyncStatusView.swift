// App/UI/Settings/SyncStatusView.swift
// UI component for displaying sync status

import SwiftUI
import SyncInterfaces
import Domain

/// View displaying current sync status
struct SyncStatusView: View {
    @ObservedObject var viewModel: SyncStatusViewModel

    var body: some View {
        VStack(spacing: 16) {
            // Status indicator
            HStack {
                statusIcon
                Text(statusText)
                    .font(.headline)
                Spacer()
            }
            .padding()
            .background(statusBackgroundColor)
            .cornerRadius(8)

            // Sync button
            Button(action: {
                Task {
                    await viewModel.sync()
                }
            }) {
                HStack {
                    if viewModel.isSyncing {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                    } else {
                        Image(systemName: "arrow.triangle.2.circlepath")
                    }
                    Text(viewModel.isSyncing ? "Syncing..." : "Sync Now")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .disabled(viewModel.isSyncing || !viewModel.isAvailable)

            // Last sync info
            if case let .success(syncedAt) = viewModel.status {
                Text("Last synced: \(formattedDate(syncedAt))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            // Error message
            if case let .failed(error) = viewModel.status {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Sync Failed")
                        .font(.headline)
                        .foregroundColor(.red)
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.red.opacity(0.1))
                .cornerRadius(8)
            }
        }
        .padding()
        .navigationTitle("Sync Status")
        .task {
            await viewModel.checkAvailability()
        }
    }

    private var statusIcon: some View {
        Group {
            switch viewModel.status {
            case .idle:
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            case .syncing:
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
            case .success:
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            case .failed:
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.red)
            case .unavailable:
                Image(systemName: "icloud.slash.fill")
                    .foregroundColor(.gray)
            }
        }
        .font(.title)
    }

    private var statusText: String {
        switch viewModel.status {
        case .idle:
            return "Ready to sync"
        case .syncing:
            return "Syncing..."
        case .success:
            return "Synced"
        case .failed:
            return "Sync failed"
        case .unavailable:
            return "iCloud unavailable"
        }
    }

    private var statusBackgroundColor: Color {
        switch viewModel.status {
        case .idle, .success:
            return Color.green.opacity(0.1)
        case .syncing:
            return Color.blue.opacity(0.1)
        case .failed:
            return Color.red.opacity(0.1)
        case .unavailable:
            return Color.gray.opacity(0.1)
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

/// View model for sync status
@MainActor
class SyncStatusViewModel: ObservableObject {
    @Published var status: SyncStatus = .idle
    @Published var isAvailable: Bool = false
    @Published var isSyncing: Bool = false

    private let syncClient: SyncClient

    init(syncClient: SyncClient) {
        self.syncClient = syncClient
    }

    func checkAvailability() async {
        isAvailable = await syncClient.checkAvailability()
        status = await syncClient.status
    }

    func sync() async {
        guard isAvailable, !isSyncing else { return }

        isSyncing = true
        let result = await syncClient.sync()

        switch result {
        case let .success(uploaded, downloaded, conflicts):
            print("Sync completed: \(uploaded) uploaded, \(downloaded) downloaded, \(conflicts) conflicts resolved")
        case let .failure(error):
            print("Sync failed: \(error)")
        }

        status = await syncClient.status
        isSyncing = false
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        SyncStatusView(viewModel: SyncStatusViewModel(syncClient: PreviewSyncClient()))
    }
}

/// Preview sync client for SwiftUI previews
private actor PreviewSyncClient: SyncClient {
    var status: SyncStatus {
        get async { .idle }
    }

    func checkAvailability() async -> Bool {
        true
    }

    func sync() async -> SyncResult {
        .success(uploadedCount: 5, downloadedCount: 3, conflictsResolved: 1)
    }

    func uploadBoard(_ board: Domain.Board) async throws {}
    func uploadList(_ list: Domain.PersonalList) async throws {}
    func uploadRecipe(_ recipe: Domain.Recipe) async throws {}
    func deleteBoard(_ boardID: Domain.BoardID) async throws {}
    func deleteList(_ listID: Domain.ListID) async throws {}
    func deleteRecipe(_ recipeID: Domain.RecipeID) async throws {}
}
