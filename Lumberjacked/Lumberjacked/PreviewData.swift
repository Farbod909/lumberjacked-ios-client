//
//  PreviewData.swift
//  Lumberjacked

#if DEBUG
import Foundation

enum PreviewData {

    // MARK: - Movement Logs

    static let log_benchPress_1 = MovementLog(
        id: 1, movement: 1, workout: 5,
        reps: [10, 10, 8], loads: [135, 135, 135],
        notes: "Felt strong today.",
        timestamp: Calendar.current.date(byAdding: .day, value: -2, to: Date())!
    )
    static let log_benchPress_2 = MovementLog(
        id: 2, movement: 1, workout: 3,
        reps: [8, 8, 7], loads: [140, 140, 140],
        notes: "",
        timestamp: Calendar.current.date(byAdding: .day, value: -9, to: Date())!
    )
    static let log_benchPress_3 = MovementLog(
        id: 3, movement: 1, workout: 1,
        reps: [8, 8, 8], loads: [130, 130, 130],
        notes: "Warm-up sets felt heavy.",
        timestamp: Calendar.current.date(byAdding: .day, value: -16, to: Date())!
    )

    static let log_squat_1 = MovementLog(
        id: 4, movement: 2, workout: 5,
        reps: [5, 5, 5], loads: [225, 225, 225],
        notes: "",
        timestamp: Calendar.current.date(byAdding: .day, value: -2, to: Date())!
    )
    static let log_squat_2 = MovementLog(
        id: 5, movement: 2, workout: 2,
        reps: [5, 5, 4], loads: [220, 220, 220],
        notes: "Hit depth on all sets.",
        timestamp: Calendar.current.date(byAdding: .day, value: -11, to: Date())!
    )

    static let log_deadlift_1 = MovementLog(
        id: 6, movement: 3, workout: 4,
        reps: [3, 3, 3], loads: [315, 315, 315],
        notes: "",
        timestamp: Calendar.current.date(byAdding: .day, value: -5, to: Date())!
    )
    static let log_deadlift_2 = MovementLog(
        id: 7, movement: 3, workout: 2,
        reps: [3, 3, 2], loads: [305, 305, 305],
        notes: "Grip gave out on last rep.",
        timestamp: Calendar.current.date(byAdding: .day, value: -12, to: Date())!
    )

    static let log_ohp_1 = MovementLog(
        id: 8, movement: 4, workout: 5,
        reps: [8, 8, 7], loads: [95, 95, 95],
        notes: "",
        timestamp: Calendar.current.date(byAdding: .day, value: -2, to: Date())!
    )

    static let log_row_1 = MovementLog(
        id: 9, movement: 5, workout: 4,
        reps: [10, 10, 10], loads: [135, 135, 135],
        notes: "Good mind-muscle connection.",
        timestamp: Calendar.current.date(byAdding: .day, value: -5, to: Date())!
    )

    // MARK: - Movements

    static let benchPress = Movement(
        id: 1, author: 1,
        name: "Barbell Bench Press", category: "Chest",
        notes: "Keep elbows tucked at 45°. Don't bounce the bar off the chest. Retract scapula before unracking.",
        recommended_warmup_sets: "2-3",
        recommended_working_sets: "3",
        recommended_rep_range: "8-12",
        recommended_rpe: "7-8",
        recommended_rest_time: 90,
        latest_log: log_benchPress_1, recorded_log: log_benchPress_1
    )

    static let squat = Movement(
        id: 2, author: 1,
        name: "Barbell Back Squat", category: "Legs",
        notes: "Go as low as possible. Put plates under heels if needed. Knees out.",
        recommended_warmup_sets: "3-4",
        recommended_working_sets: "3",
        recommended_rep_range: "4-6",
        recommended_rpe: "8",
        recommended_rest_time: 180,
        latest_log: log_squat_1, recorded_log: log_squat_1
    )

    static let deadlift = Movement(
        id: 3, author: 1,
        name: "Conventional Deadlift", category: "Back",
        notes: "Brace hard before pulling. Keep bar close to the body. Do not round lower back.",
        recommended_warmup_sets: "2-3",
        recommended_working_sets: "2",
        recommended_rep_range: "3-5",
        recommended_rpe: "8-9",
        recommended_rest_time: 240,
        latest_log: log_deadlift_1, recorded_log: log_deadlift_1
    )

    static let ohp = Movement(
        id: 4, author: 1,
        name: "Overhead Press", category: "Shoulders",
        notes: "Squeeze glutes and abs throughout. Bar path should be slightly back.",
        recommended_warmup_sets: "2",
        recommended_working_sets: "3",
        recommended_rep_range: "6-10",
        recommended_rpe: "7-8",
        recommended_rest_time: 90,
        latest_log: log_ohp_1, recorded_log: log_ohp_1
    )

    static let bentOverRow = Movement(
        id: 5, author: 1,
        name: "Barbell Bent-Over Row", category: "Back",
        notes: "Hinge at hips until torso is ~45°. Pull to lower chest.",
        recommended_warmup_sets: "2",
        recommended_working_sets: "3",
        recommended_rep_range: "8-12",
        recommended_rpe: "7",
        recommended_rest_time: 90,
        latest_log: log_row_1, recorded_log: log_row_1
    )

    static let inclineDumbbell = Movement(
        id: 6, author: 1,
        name: "Incline Dumbbell Press", category: "Chest",
        notes: "15-30° incline. Control the eccentric.",
        recommended_warmup_sets: "1",
        recommended_working_sets: "3",
        recommended_rep_range: "10-15",
        recommended_rpe: "7",
        recommended_rest_time: 60,
        latest_log: nil, recorded_log: nil
    )

    static let romanianDeadlift = Movement(
        id: 7, author: 1,
        name: "Romanian Deadlift", category: "Legs",
        notes: "Hinge until you feel hamstring stretch. Soft knee bend. No rounding.",
        recommended_warmup_sets: "1",
        recommended_working_sets: "3",
        recommended_rep_range: "8-10",
        recommended_rpe: "7",
        recommended_rest_time: 90,
        latest_log: nil, recorded_log: nil
    )

    static let cableRow = Movement(
        id: 8, author: 1,
        name: "Seated Cable Row", category: "Back",
        notes: "Full stretch at the front. Elbows tight to sides on pull.",
        recommended_warmup_sets: "",
        recommended_working_sets: "3",
        recommended_rep_range: "12-15",
        recommended_rpe: "6-7",
        recommended_rest_time: 60,
        latest_log: nil, recorded_log: nil
    )

    static let latPulldown = Movement(
        id: 9, author: 1,
        name: "Lat Pulldown", category: "Back",
        notes: "Lean back slightly. Pull to upper chest, not behind neck.",
        recommended_warmup_sets: "",
        recommended_working_sets: "3",
        recommended_rep_range: "10-12",
        recommended_rpe: "7",
        recommended_rest_time: 60,
        latest_log: nil, recorded_log: nil
    )

    static let movements: [Movement] = [
        benchPress, squat, deadlift, ohp, bentOverRow,
        inclineDumbbell, romanianDeadlift, cableRow, latPulldown
    ]

    // MARK: - Workouts

    static let activeWorkout = Workout(
        id: 10,
        movements: [1, 4, 5],
        start_timestamp: Calendar.current.date(byAdding: .minute, value: -47, to: Date())!,
        movements_details: [benchPress, ohp, bentOverRow]
    )

    static let pastWorkout_today = Workout(
        id: 5,
        movements: [1, 2, 4],
        start_timestamp: Calendar.current.date(byAdding: .hour, value: -4, to: Date())!,
        end_timestamp: Calendar.current.date(byAdding: .hour, value: -2, to: Date())!,
        movements_details: [
            Movement(id: 1, author: 1, name: "Barbell Bench Press", category: "Chest", notes: "", recommended_warmup_sets: "2-3", recommended_working_sets: "3", recommended_rep_range: "8-12", recommended_rpe: "7-8", recommended_rest_time: 90, latest_log: log_benchPress_1, recorded_log: log_benchPress_1),
            Movement(id: 2, author: 1, name: "Barbell Back Squat", category: "Legs", notes: "", recommended_warmup_sets: "3-4", recommended_working_sets: "3", recommended_rep_range: "4-6", recommended_rpe: "8", recommended_rest_time: 180, latest_log: log_squat_1, recorded_log: log_squat_1),
            Movement(id: 4, author: 1, name: "Overhead Press", category: "Shoulders", notes: "", recommended_warmup_sets: "2", recommended_working_sets: "3", recommended_rep_range: "6-10", recommended_rpe: "7-8", recommended_rest_time: 90, latest_log: log_ohp_1, recorded_log: log_ohp_1)
        ]
    )

    static let pastWorkout_2daysAgo = Workout(
        id: 4,
        movements: [3, 5],
        start_timestamp: Calendar.current.date(byAdding: .day, value: -2, to: Date())!,
        end_timestamp: Calendar.current.date(byAdding: .day, value: -2, to: Date())!,
        movements_details: [
            Movement(id: 3, author: 1, name: "Conventional Deadlift", category: "Back", notes: "", recommended_warmup_sets: "2-3", recommended_working_sets: "2", recommended_rep_range: "3-5", recommended_rpe: "8-9", recommended_rest_time: 240, latest_log: log_deadlift_1, recorded_log: log_deadlift_1),
            Movement(id: 5, author: 1, name: "Barbell Bent-Over Row", category: "Back", notes: "", recommended_warmup_sets: "2", recommended_working_sets: "3", recommended_rep_range: "8-12", recommended_rpe: "7", recommended_rest_time: 90, latest_log: log_row_1, recorded_log: log_row_1)
        ]
    )

    static let pastWorkout_lastWeek = Workout(
        id: 3,
        movements: [1, 2, 4],
        start_timestamp: Calendar.current.date(byAdding: .day, value: -7, to: Date())!,
        end_timestamp: Calendar.current.date(byAdding: .day, value: -7, to: Date())!,
        movements_details: [
            Movement(id: 1, author: 1, name: "Barbell Bench Press", category: "Chest", notes: "", recommended_warmup_sets: "2-3", recommended_working_sets: "3", recommended_rep_range: "8-12", recommended_rpe: "7-8", recommended_rest_time: 90, latest_log: log_benchPress_2, recorded_log: log_benchPress_2),
            Movement(id: 2, author: 1, name: "Barbell Back Squat", category: "Legs", notes: "", recommended_warmup_sets: "3-4", recommended_working_sets: "3", recommended_rep_range: "4-6", recommended_rpe: "8", recommended_rest_time: 180, latest_log: log_squat_2, recorded_log: log_squat_2),
            Movement(id: 4, author: 1, name: "Overhead Press", category: "Shoulders", notes: "", recommended_warmup_sets: "2", recommended_working_sets: "3", recommended_rep_range: "6-10", recommended_rpe: "7-8", recommended_rest_time: 90, latest_log: log_ohp_1, recorded_log: log_ohp_1)
        ]
    )

    static let pastWorkout_2weeksAgo = Workout(
        id: 2,
        movements: [3, 5, 2],
        start_timestamp: Calendar.current.date(byAdding: .day, value: -14, to: Date())!,
        end_timestamp: Calendar.current.date(byAdding: .day, value: -14, to: Date())!,
        movements_details: [
            Movement(id: 3, author: 1, name: "Conventional Deadlift", category: "Back", notes: "", recommended_warmup_sets: "2-3", recommended_working_sets: "2", recommended_rep_range: "3-5", recommended_rpe: "8-9", recommended_rest_time: 240, latest_log: log_deadlift_2, recorded_log: log_deadlift_2),
            Movement(id: 5, author: 1, name: "Barbell Bent-Over Row", category: "Back", notes: "", recommended_warmup_sets: "2", recommended_working_sets: "3", recommended_rep_range: "8-12", recommended_rpe: "7", recommended_rest_time: 90, latest_log: log_row_1, recorded_log: log_row_1),
            Movement(id: 2, author: 1, name: "Barbell Back Squat", category: "Legs", notes: "", recommended_warmup_sets: "3-4", recommended_working_sets: "3", recommended_rep_range: "4-6", recommended_rpe: "8", recommended_rest_time: 180, latest_log: log_squat_2, recorded_log: log_squat_2)
        ]
    )

    static let pastWorkout_3weeksAgo = Workout(
        id: 1,
        movements: [1, 2, 4],
        start_timestamp: Calendar.current.date(byAdding: .day, value: -21, to: Date())!,
        end_timestamp: Calendar.current.date(byAdding: .day, value: -21, to: Date())!,
        movements_details: [
            Movement(id: 1, author: 1, name: "Barbell Bench Press", category: "Chest", notes: "", recommended_warmup_sets: "2-3", recommended_working_sets: "3", recommended_rep_range: "8-12", recommended_rpe: "7-8", recommended_rest_time: 90, latest_log: log_benchPress_3, recorded_log: log_benchPress_3),
            Movement(id: 2, author: 1, name: "Barbell Back Squat", category: "Legs", notes: "", recommended_warmup_sets: "3-4", recommended_working_sets: "3", recommended_rep_range: "4-6", recommended_rpe: "8", recommended_rest_time: 180, latest_log: log_squat_2, recorded_log: log_squat_2),
            Movement(id: 4, author: 1, name: "Overhead Press", category: "Shoulders", notes: "", recommended_warmup_sets: "2", recommended_working_sets: "3", recommended_rep_range: "6-10", recommended_rpe: "7-8", recommended_rest_time: 90, latest_log: log_ohp_1, recorded_log: log_ohp_1)
        ]
    )

    static let pastWorkouts: [Workout] = [
        pastWorkout_today, pastWorkout_2daysAgo,
        pastWorkout_lastWeek, pastWorkout_2weeksAgo, pastWorkout_3weeksAgo
    ]

    static let benchPressLogs: [MovementLog] = [log_benchPress_1, log_benchPress_2, log_benchPress_3]
}
#endif
