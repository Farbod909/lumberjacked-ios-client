//
//  WorkoutOverviewView.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 1/30/25.
//

import SwiftUI

struct WorkoutOverviewView: View {
    @State var workout: Workout
    
    var body: some View {
        VStack {
            Group {
                Text(String(workout.humanReadableStartTimestamp!))
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.bottom, 2)
                ForEach(workout.movements_details!, id: \.self.id!) { movement in
                    HStack {
                        Text(movement.name)
                        Spacer()
                        Group {
                            if let recorded_log = movement.recorded_log {
                                if let setsNum = recorded_log.reps?.count {
                                    if setsNum > 1 {
                                        Text("\(setsNum) Sets")
                                    } else {
                                        Text("\(setsNum) Set")
                                    }
                                } else {
                                    Text("Unknown")
                                }
                            } else {
                                Text("Skipped")
                            }
                        }
                        .textCase(.uppercase)
                        .font(.caption)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#Preview {
    WorkoutOverviewView(workout: Workout())
}
