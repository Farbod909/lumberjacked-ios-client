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
        return movement.latest_log
    }

    var body: some View {
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
                        Text("\(movement.name)\u{FEFF} \u{FEFF}\(Image(systemName: isExpanded ? "chevron.up" : "chevron.down"))")
                            .textCase(.uppercase)
                            .fontWeight(.bold)
                            .foregroundStyle(.foreground)
                            .multilineTextAlignment(.leading)
                    }
                }
                Spacer()
                NavigationLink(
                    value: MovementLogDestination(
                        log: movementDone
                            ? movement.latest_log!
                            : movement.latest_log?.withJustInputFields ?? MovementLog(notes: ""),
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
                    HStack(alignment: .top) {
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
                                    Text("None")
                                }
                            }
                        }
                        Spacer()
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
}

#if DEBUG
#Preview {
    CurrentWorkoutMovementView(movement: PreviewData.benchPress, isExpanded: true)
}
#endif
