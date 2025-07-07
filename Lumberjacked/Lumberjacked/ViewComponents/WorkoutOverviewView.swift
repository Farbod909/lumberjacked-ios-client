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
                ForEach(workout.movements_details!, id: \.self.id!) { movement in
                    HStack {
                        Text(movement.name)
                        Spacer()
                        if let recorded_log = movement.recorded_log {
                            Text(recorded_log.setsAndRepsString)
                        } else {
                            Text("Skipped")
                        }
                        
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
