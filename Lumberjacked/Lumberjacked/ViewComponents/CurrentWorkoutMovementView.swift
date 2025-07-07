//
//  CurrentWorkoutMovementView.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 2/5/25.
//

import SwiftUI

struct CurrentWorkoutMovementView: View {
    @State var movement: Movement
    
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
    
    var body: some View {
        HStack {
            Button {
                // Show movement detail page
            } label: {
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
            Button {
                // Show movement log creation page
            } label: {
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
}
