//
//  MovementDetailView.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 1/22/25.
//

import SwiftUI

struct MovementDetailView: View {
    @State var viewModel: ViewModel
    @State var errors = LumberjackedClientErrors()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                VStack(alignment: .leading) {
                    if viewModel.movement.hasCategory {
                        HStack {
                            Text("category")
                                .textCase(.uppercase)
                                .font(.headline)
                            Text(viewModel.movement.category!)
                                .foregroundColor(.primary)
                            Spacer()
                        }
                        .padding(EdgeInsets(top: 4, leading: 0, bottom: 10 , trailing: 0))
                        .overlay(Divider().background(.primary), alignment: .bottom)
                    }
                    
                    if viewModel.movement.hasNotes {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Notes")
                                    .textCase(.uppercase)
                                    .font(.headline)
                                Text(viewModel.movement.notes!)
                                    .foregroundColor(.primary)
                            }
                            Spacer()
                        }
                        .padding(EdgeInsets(top: 4, leading: 0, bottom: 10 , trailing: 0))
                        .overlay(Divider().background(.primary), alignment: .bottom)
                    }
                    
                    if viewModel.movement.hasAnyRecommendations {
                        HStack {
                            RecommendationsView(movement: viewModel.movement)
                            Spacer()
                        }
                        .padding(EdgeInsets(top: 4, leading: 0, bottom: 10 , trailing: 0))
                        .overlay(Divider().background(.primary), alignment: .bottom)
                    }
                }
                
                if !viewModel.movementLogs.isEmpty {
                    LogListView(movementLogs: viewModel.movementLogs)
                } else {
                    Spacer()
                    Text("No logs yet :/")
                        .padding()
                    Spacer()
                }
                Spacer()
            }
        }
        .navigationTitle(viewModel.movement.name!)
        .task {
            await viewModel.attemptGetMovementLogs(errors: $errors)
        }
        .toolbar {
            if viewModel.deleteActionLoading {
                ToolbarItem(placement: .topBarTrailing) {
                    ProgressView()
                }
            }
            if viewModel.workout != nil {
                ToolbarItem(placement: .primaryAction) {
                    NavigationLink() {
                        Text("new log page")
                    } label: {
                        Label("New log", systemImage: "plus.square.fill")
                    }
                }
            }
            ToolbarItemGroup(placement: .secondaryAction) {
                NavigationLink {
                    Text("edit movement page")
                } label: {
                    Label("Edit movement", systemImage: "pencil.circle")
                }
                Button {
                    viewModel.showDeleteConfirmationAlert = true
                } label: {
                    Label("Delete movement", systemImage: "trash")
                }
            }
        }
        .navigationDestination(for: Movement.self) { selection in
            // edit log
        }
        .alert("Delete", isPresented: $viewModel.showDeleteConfirmationAlert) {
            Button("Delete", role: .destructive) {
                Task {
                    guard await viewModel.attemptDeleteMovement(id: viewModel.movement.id!, errors: $errors) else {
                        return
                    }
                    dismiss()
                }
            }
            Button("Cancel", role: .cancel) {}
        }
        .padding(.horizontal, 16)
    }
}

struct RecommendationsView: View {
    let movement: Movement
    
    struct Recommendation: Hashable, Equatable {
        let name: String
        let value: String
    }
    
    var recommendations: [Recommendation] {
        var result = [Recommendation]()
        if let warmupSets = movement.recommended_warmup_sets {
            result.append(Recommendation(name: "Warmup Sets", value: warmupSets))
        }
        if let workingSets = movement.recommended_working_sets {
            result.append(Recommendation(name: "Working Sets", value: workingSets))
        }
        if let repRange = movement.recommended_rep_range {
            result.append(Recommendation(name: "Rep Range", value: repRange))
        }
        if let rpe = movement.recommended_rpe {
            result.append(Recommendation(name: "RPE", value: rpe))
        }
        if let restTime = movement.recommended_rest_time {
            let minutes: UInt16 = restTime / 60
            let seconds: UInt16 = restTime % 60
            var value = ""
            if minutes > 0 {
                value.append("\(minutes)m")
            }
            if seconds > 0 {
                value.append("\(seconds)s")
            }
            result.append(Recommendation(name: "Rest", value: value))
        }
        return result
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Recommendations")
                .textCase(.uppercase)
                .font(.headline)
            VStack(alignment: .leading, spacing: 0) {
                ForEach(recommendations, id: \.self) { recommendation in
                    HStack {
                        Text(recommendation.name)
                            .textCase(.uppercase)
                            .font(.subheadline)
                            .fontWidth(.condensed)
                            .fontWeight(.semibold)
                        Text(recommendation.value)
                    }
                    .padding(0)
                }
            }
            .foregroundColor(.primary)
        }
    }
}

struct LogListView: View {
    var movementLogs: [MovementLog]
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Logs")
                    .textCase(.uppercase)
                    .font(.headline)
                Spacer()
            }
            LazyVStack {
                ForEach(
                     movementLogs.sorted(
                        by: { $0.timestamp! > $1.timestamp! }
                    ),
                    id: \.self
                ) { log in
                    LogItem(movementLog: log)
                }
            }
        }
        .padding(EdgeInsets(top: 8, leading: 0, bottom: 0, trailing: 0))
    }
}

struct LogItem: View {
    let movementLog: MovementLog
    
    var body: some View {
        NavigationLink(value: movementLog) {
            HStack {
                if let timestamp = movementLog.timestamp {
                    Text(timestamp.formatted(date: .abbreviated, time: .omitted))
                        .fontWeight(.semibold)
                }
                Spacer()
                VStack(alignment: .trailing) {
                    ForEach(movementLog.summary, id:\.self) { item in
                        Text(item)
                    }
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 12)
            .background(Color.init(uiColor: .systemGray6))
            .foregroundColor(.primary)
            .cornerRadius(5)
            .padding(.bottom, 2)
        }
    }
}
