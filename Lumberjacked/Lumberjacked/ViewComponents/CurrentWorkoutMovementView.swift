//
//  CurrentWorkoutMovementView.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 2/5/25.
//

import SwiftUI

struct CurrentWorkoutMovementView: View {
    @State var movement: Movement
    @State var isExpanded = false
    
    var movementDone: Bool {
        if let for_current_workout = latestLog?.for_current_workout {
            return for_current_workout
        }
        return false
    }
    
    var latestLog: MovementLog? {
        if let latest_log = movement.latest_log {
            return latest_log
        }
        return nil
    }
    
    var version1: some View {
        HStack {
            NavigationLink(value: movement) {
                Image(systemName: "info.circle")
                    .font(.title2)
            }
            Spacer()
            VStack {
                Text(movement.name)
                    .font(.title3)
                    .fontWeight(.bold)
                Group {
                    if movementDone {
                        Text("Today")
                    } else {
                        Text("Most Recent")
                    }
                }
                .font(.footnote)
                .fontWidth(.condensed)
                .fontWeight(.semibold)
                .textCase(.uppercase)
                Group {
                    if let latestLog = movement.latest_log {
                        ForEach(latestLog.summary, id: \.self) { item in
                            Text(item)
                        }
                    } else {
                        Text("N/A")
                    }
                }
                .font(.footnote)
            }
            Spacer()
            NavigationLink(
                value: MovementLogDestination(
                    log: movementDone ? movement.latest_log! : movement.latest_log?.withJustInputFields ?? MovementLog(reps: [], loads: [], notes: ""),
                    movement: movement))
            {
                Image(systemName: movementDone ? "checkmark" : "square.and.pencil")
                    .font(.title2)
            }
        }
        .padding()
        .background(.regularMaterial)
        .background(movementDone ? .green : .clear)
        .foregroundStyle(.primary)
        .clipShape(.rect(cornerRadius: 20))
    }
    
    var version2: some View {
        VStack {
            HStack {
                if movementDone {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                }
                Button(action: {
                    withAnimation {
                        isExpanded.toggle()
                    }
                }) {
                    HStack(alignment: .bottom) {
                        Text("\(movement.name)\u{FEFF} \u{FEFF}\(Image(systemName: isExpanded ? "chevron.up.circle" : "chevron.down.circle"))")
                            .textCase(.uppercase)
                            .fontWeight(.bold)
                            .foregroundStyle(.foreground)
                            .multilineTextAlignment(.leading)
                    }
                }
                Spacer()
                NavigationLink(
                    value: MovementLogDestination(
                        log: movementDone ? movement.latest_log! : movement.latest_log?.withJustInputFields ?? MovementLog(reps: [], loads: [], notes: ""),
                        movement: movement))
                {
                    HStack {
                        Text(movementDone ? "Edit" : "Log")
                        Image(systemName: "pencil.circle")
                    }
                }
                .foregroundStyle(.accent)
            }
            .font(.system(size: 20))
            if isExpanded {
                VStack {
                    HStack {
                        VStack(alignment: .leading) {
                            Group {
                                if movementDone {
                                    Text("Today")
                                } else {
                                    Text("Most Recent")
                                }
                            }
                            .fontWeight(.semibold)
                            .textCase(.uppercase)
                            Group {
                                if let latestLog = movement.latest_log {
                                    ForEach(latestLog.summary, id: \.self) { item in
                                        Text(item).textCase(.uppercase)
                                    }
                                } else {
                                    Text("N/A")
                                }
                            }
                        }
                        Spacer()
                        VStack(alignment: .trailing) {
                            if movement.hasAnyRecommendations {
                                Text("Recommended")
                                    .fontWeight(.semibold)
                                    .textCase(.uppercase)
                                Group {
                                    if !movement.recommended_warmup_sets.isEmpty {
                                        Text(movement.recommended_warmup_sets + " Warmup set(s)")
                                            .textCase(.uppercase)
                                    }
                                    if !movement.recommended_working_sets.isEmpty {
                                        Text(movement.recommended_working_sets + " Working set(s)")
                                            .textCase(.uppercase)
                                    }
                                    if !movement.recommended_rep_range.isEmpty {
                                        Text(movement.recommended_rep_range + " Reps")
                                            .textCase(.uppercase)
                                    }
                                }
                            }
                        }
                    }
                    HStack {
                        Spacer()
                        NavigationLink(value: movement) {
                            Label("See more...", systemImage: "info.circle")
                            
                        }
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    }
                    .padding(EdgeInsets(top: 2, leading: 0, bottom: 0, trailing: 0))
                }
                .padding(EdgeInsets(top: 4, leading: 0, bottom: 0, trailing: 0))

            }
        }
        .padding(EdgeInsets(top: 4, leading: 0, bottom: 14, trailing: 0))
        .overlay(
            Divider().background(.foreground).frame(height: 2).overlay(.foreground),
            alignment: .bottom)
    }
    
    var body: some View {
        version2
    }
    
}

#Preview {
    CurrentWorkoutMovementView(movement: Movement.init(name: "Example", category: "Lower Body", notes: "", recommended_warmup_sets: "", recommended_working_sets: "", recommended_rep_range: "", recommended_rpe: ""), isExpanded: true)
}
