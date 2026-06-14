//
//  PreviewData.swift
//  Lumberjacked

#if DEBUG
import Foundation

enum PreviewData {

    // MARK: - Log Sets

    static func workingSets(reps: Int, load: Double, count: Int) -> [LogSet] {
        Array(repeating: LogSet(reps: reps, load: load, type: "working"), count: count)
    }

    // MARK: - Movement Logs

    static let log_benchPress_1 = MovementLog(
        id: 1, workout_movement: 101,
        sets: workingSets(reps: 10, load: 135, count: 3),
        notes: "Felt strong today.",
        timestamp: Calendar.current.date(byAdding: .day, value: -2, to: Date())!
    )
    static let log_benchPress_2 = MovementLog(
        id: 2, workout_movement: 201,
        sets: workingSets(reps: 8, load: 140, count: 3),
        notes: "",
        timestamp: Calendar.current.date(byAdding: .day, value: -9, to: Date())!
    )
    static let log_benchPress_3 = MovementLog(
        id: 3, workout_movement: 301,
        sets: workingSets(reps: 8, load: 130, count: 3),
        notes: "Warm-up sets felt heavy.",
        timestamp: Calendar.current.date(byAdding: .day, value: -16, to: Date())!
    )

    static let log_squat_1 = MovementLog(
        id: 4, workout_movement: 102,
        sets: workingSets(reps: 5, load: 225, count: 3),
        notes: "",
        timestamp: Calendar.current.date(byAdding: .day, value: -2, to: Date())!
    )
    static let log_squat_2 = MovementLog(
        id: 5, workout_movement: 202,
        sets: [
            LogSet(reps: 5, load: 220, type: "working"),
            LogSet(reps: 5, load: 220, type: "working"),
            LogSet(reps: 4, load: 220, type: "failure"),
        ],
        notes: "Hit depth on all sets.",
        timestamp: Calendar.current.date(byAdding: .day, value: -11, to: Date())!
    )

    static let log_deadlift_1 = MovementLog(
        id: 6, workout_movement: 401,
        sets: workingSets(reps: 3, load: 315, count: 3),
        notes: "",
        timestamp: Calendar.current.date(byAdding: .day, value: -5, to: Date())!
    )
    static let log_deadlift_2 = MovementLog(
        id: 7, workout_movement: 203,
        sets: [
            LogSet(reps: 3, load: 305, type: "working"),
            LogSet(reps: 3, load: 305, type: "working"),
            LogSet(reps: 2, load: 305, type: "failure"),
        ],
        notes: "Grip gave out on last rep.",
        timestamp: Calendar.current.date(byAdding: .day, value: -12, to: Date())!
    )

    static let log_ohp_1 = MovementLog(
        id: 8, workout_movement: 103,
        sets: workingSets(reps: 8, load: 95, count: 3),
        notes: "",
        timestamp: Calendar.current.date(byAdding: .day, value: -2, to: Date())!
    )

    static let log_row_1 = MovementLog(
        id: 9, workout_movement: 402,
        sets: workingSets(reps: 10, load: 135, count: 3),
        notes: "Good mind-muscle connection.",
        timestamp: Calendar.current.date(byAdding: .day, value: -5, to: Date())!
    )

    // MARK: - Movements

    static let benchPress = Movement(
        id: 1, author: 1,
        name: "Barbell Bench Press",
        notes: "Keep elbows tucked at 45°. Don't bounce the bar off the chest. Retract scapula before unracking.",
        resistance_type: "barbell",
        body_part: "chest",
        latest_log: log_benchPress_1, recorded_log: log_benchPress_1,
        workout_movement_id: 101
    )

    static let squat = Movement(
        id: 2, author: 1,
        name: "Barbell Back Squat",
        notes: "Go as low as possible. Put plates under heels if needed. Knees out.",
        resistance_type: "barbell",
        body_part: "quads",
        latest_log: log_squat_1, recorded_log: log_squat_1,
        workout_movement_id: 102
    )

    static let deadlift = Movement(
        id: 3, author: 1,
        name: "Conventional Deadlift",
        notes: "Brace hard before pulling. Keep bar close to the body. Do not round lower back.",
        resistance_type: "barbell",
        body_part: "back",
        latest_log: log_deadlift_1, recorded_log: log_deadlift_1
    )

    static let ohp = Movement(
        id: 4, author: 1,
        name: "Overhead Press",
        notes: "Squeeze glutes and abs throughout. Bar path should be slightly back.",
        resistance_type: "barbell",
        body_part: "shoulders",
        latest_log: log_ohp_1, recorded_log: log_ohp_1,
        workout_movement_id: 103
    )

    static let bentOverRow = Movement(
        id: 5, author: 1,
        name: "Barbell Bent-Over Row",
        notes: "Hinge at hips until torso is ~45°. Pull to lower chest.",
        resistance_type: "barbell",
        body_part: "back",
        latest_log: log_row_1, recorded_log: log_row_1,
        workout_movement_id: 104
    )

    static let inclineDumbbell = Movement(
        id: 6, author: 1,
        name: "Incline Dumbbell Press",
        notes: "15-30° incline. Control the eccentric.",
        resistance_type: "dumbbell",
        body_part: "chest",
        latest_log: nil, recorded_log: nil
    )

    static let romanianDeadlift = Movement(
        id: 7, author: 1,
        name: "Romanian Deadlift",
        notes: "Hinge until you feel hamstring stretch. Soft knee bend. No rounding.",
        resistance_type: "barbell",
        body_part: "hamstrings",
        latest_log: nil, recorded_log: nil
    )

    static let cableRow = Movement(
        id: 8, author: 1,
        name: "Seated Cable Row",
        notes: "Full stretch at the front. Elbows tight to sides on pull.",
        resistance_type: "cable",
        body_part: "back",
        latest_log: nil, recorded_log: nil
    )

    static let latPulldown = Movement(
        id: 9, author: 1,
        name: "Lat Pulldown",
        notes: "Lean back slightly. Pull to upper chest, not behind neck.",
        resistance_type: "cable",
        body_part: "lats",
        latest_log: nil, recorded_log: nil
    )

    static let movements: [Movement] = [
        benchPress, squat, deadlift, ohp, bentOverRow,
        inclineDumbbell, romanianDeadlift, cableRow, latPulldown
    ]

    // MARK: - Workouts

    static let activeWorkout = Workout(
        id: 10,
        start_timestamp: Calendar.current.date(byAdding: .minute, value: -47, to: Date())!,
        movements_details: [benchPress, ohp, bentOverRow]
    )

    static let pastWorkout_today = Workout(
        id: 5,
        start_timestamp: Calendar.current.date(byAdding: .hour, value: -4, to: Date())!,
        end_timestamp: Calendar.current.date(byAdding: .hour, value: -2, to: Date())!,
        movements_details: [
            Movement(id: 1, author: 1, name: "Barbell Bench Press", notes: "", resistance_type: "barbell", latest_log: log_benchPress_1, recorded_log: log_benchPress_1, workout_movement_id: 501),
            Movement(id: 2, author: 1, name: "Barbell Back Squat", notes: "", resistance_type: "barbell", latest_log: log_squat_1, recorded_log: log_squat_1, workout_movement_id: 502),
            Movement(id: 4, author: 1, name: "Overhead Press", notes: "", resistance_type: "barbell", latest_log: log_ohp_1, recorded_log: log_ohp_1, workout_movement_id: 503)
        ]
    )

    static let pastWorkout_2daysAgo = Workout(
        id: 4,
        start_timestamp: Calendar.current.date(byAdding: .day, value: -2, to: Date())!,
        end_timestamp: Calendar.current.date(byAdding: .day, value: -2, to: Date())!,
        movements_details: [
            Movement(id: 3, author: 1, name: "Conventional Deadlift", notes: "", resistance_type: "barbell", latest_log: log_deadlift_1, recorded_log: log_deadlift_1, workout_movement_id: 401),
            Movement(id: 5, author: 1, name: "Barbell Bent-Over Row", notes: "", resistance_type: "barbell", latest_log: log_row_1, recorded_log: log_row_1, workout_movement_id: 402)
        ]
    )

    static let pastWorkout_lastWeek = Workout(
        id: 3,
        start_timestamp: Calendar.current.date(byAdding: .day, value: -7, to: Date())!,
        end_timestamp: Calendar.current.date(byAdding: .day, value: -7, to: Date())!,
        movements_details: [
            Movement(id: 1, author: 1, name: "Barbell Bench Press", notes: "", resistance_type: "barbell", latest_log: log_benchPress_2, recorded_log: log_benchPress_2, workout_movement_id: 301),
            Movement(id: 2, author: 1, name: "Barbell Back Squat", notes: "", resistance_type: "barbell", latest_log: log_squat_2, recorded_log: log_squat_2, workout_movement_id: 302),
            Movement(id: 4, author: 1, name: "Overhead Press", notes: "", resistance_type: "barbell", latest_log: log_ohp_1, recorded_log: log_ohp_1, workout_movement_id: 303)
        ]
    )

    static let pastWorkout_2weeksAgo = Workout(
        id: 2,
        start_timestamp: Calendar.current.date(byAdding: .day, value: -14, to: Date())!,
        end_timestamp: Calendar.current.date(byAdding: .day, value: -14, to: Date())!,
        movements_details: [
            Movement(id: 3, author: 1, name: "Conventional Deadlift", notes: "", resistance_type: "barbell", latest_log: log_deadlift_2, recorded_log: log_deadlift_2, workout_movement_id: 201),
            Movement(id: 5, author: 1, name: "Barbell Bent-Over Row", notes: "", resistance_type: "barbell", latest_log: log_row_1, recorded_log: log_row_1, workout_movement_id: 202),
            Movement(id: 2, author: 1, name: "Barbell Back Squat", notes: "", resistance_type: "barbell", latest_log: log_squat_2, recorded_log: log_squat_2, workout_movement_id: 203)
        ]
    )

    static let pastWorkout_3weeksAgo = Workout(
        id: 1,
        start_timestamp: Calendar.current.date(byAdding: .day, value: -21, to: Date())!,
        end_timestamp: Calendar.current.date(byAdding: .day, value: -21, to: Date())!,
        movements_details: [
            Movement(id: 1, author: 1, name: "Barbell Bench Press", notes: "", resistance_type: "barbell", latest_log: log_benchPress_3, recorded_log: log_benchPress_3, workout_movement_id: 101),
            Movement(id: 2, author: 1, name: "Barbell Back Squat", notes: "", resistance_type: "barbell", latest_log: log_squat_2, recorded_log: log_squat_2, workout_movement_id: 102),
            Movement(id: 4, author: 1, name: "Overhead Press", notes: "", resistance_type: "barbell", latest_log: log_ohp_1, recorded_log: log_ohp_1, workout_movement_id: 103)
        ]
    )

    static let pastWorkouts: [Workout] = [
        pastWorkout_today, pastWorkout_2daysAgo,
        pastWorkout_lastWeek, pastWorkout_2weeksAgo, pastWorkout_3weeksAgo
    ]

    static let benchPressLogs: [MovementLog] = [log_benchPress_1, log_benchPress_2, log_benchPress_3]
}
#endif
