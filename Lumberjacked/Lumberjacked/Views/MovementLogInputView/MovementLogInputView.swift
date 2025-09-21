//
//  MovementLogInputView.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 1/22/25.
//

import SwiftUI

struct MovementLogInputView: View {
    @State var viewModel: ViewModel
    @State var errors = LumberjackedClientErrors()

    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            Picker("Input Style", selection: $viewModel.selectedInputStyle) {
                ForEach(viewModel.inputStyles, id: \.self) {
                    Text($0)
                }
            }
            .pickerStyle(.segmented)
            .padding()
            if viewModel.selectedInputStyle == "Equal Sets" {
                VStack {
                    CustomIntStepper(label: "Sets", value: $viewModel.equalSetsMovementLogInput.sets, minValue: 0, maxValue: 100)
                    CustomIntStepper(label: "Reps", value: $viewModel.equalSetsMovementLogInput.reps, minValue: 0, maxValue: 100)
                    CustomDoubleStepper(label: "Load", value: $viewModel.equalSetsMovementLogInput.load, minValue: -1000, maxValue: 1000, increment: 5)
                    TextField("",
                              text: $viewModel.movementLog.notes,
                              prompt: Text("Notes").foregroundStyle(Color.secondary), axis: .vertical)
                    .padding()
                    .background(Color.init(.systemGray6))
                    .foregroundColor(Color.primary)
                    .clipShape(
                        RoundedRectangle(cornerRadius: 20)
                    )
                    .lineLimit(5)
                    Spacer()
                }
                .padding()
            } else if viewModel.selectedInputStyle == "Custom Sets" {
                VStack {
                    Text("Custom Sets Input under construction...")
                    Spacer()
                }
            } else {
                VStack {
                    Text("Unexpected input style selection.")
                    Spacer()
                }
            }
        }
        .toolbar {
            if viewModel.toolbarActionLoading {
                ToolbarItem(placement: .topBarTrailing) {
                    ProgressView()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    Task {
                        await viewModel.formSubmit(errors: $errors, dismissAction: { dismiss() })
                    }
                }
                .disabled(!viewModel.canSave())
            }
            if viewModel.movementLog.id != nil {
                ToolbarItem(placement: .secondaryAction) {
                    Button("Delete log", systemImage: "trash") {
                        Task {
                            await viewModel.attemptDeleteLog(
                                errors: $errors, dismissAction: { dismiss() })
                        }
                    }
                }
            }
        }

        .navigationTitle(
            viewModel.movementLog.timestamp?.formatted(
                date: .abbreviated,
                time: .omitted) ??
            "New Log"
        )
    }
}

struct CustomIntStepper : View {
    var label: String
    @Binding var value: UInt16?
    var minValue: UInt16
    var maxValue: UInt16
    
    var body: some View {
        HStack {
            Button {
                if value != nil {
                    if value! > minValue {
                        value = value! - 1
                    } else {
                        value = 0
                    }
                }
            } label: {
                Image(systemName: "minus")
                    .padding()
            }
            .disabled(value == minValue)
            
            VStack {
                ClearOnTapValueField(value: $value, format: .number)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.center)
                    .font(.title2)
                Text(label)
                    .font(.caption)
                    .textCase(.uppercase)
            }

            Button {
                if value != nil {
                    if value! < maxValue {
                        value = value! + 1
                    }
                } else {
                    value = 0
                }
            } label: {
                Image(systemName: "plus")
                    .padding()
            }
            .disabled(value == maxValue)
        }
        .padding(2)
        .background(Color.init(.systemGray6))
        .foregroundStyle(Color.primary)
        .font(.title2)
        .clipShape(
            RoundedRectangle(cornerRadius: 100)
        )
        .sensoryFeedback(trigger: value ?? 0) { oldValue, newValue in
            if oldValue > newValue {
                return .decrease
            } else {
                return .increase
            }
        }
    }
}

struct CustomDoubleStepper : View {
    var label: String
    @Binding var value: Double?
    var minValue: Double
    var maxValue: Double
    var increment: Double
    
    var body: some View {
        HStack {
            Button {
                if value != nil {
                    if value! > minValue {
                        value = value! - increment
                    } else {
                        value = 0.0
                    }
                }
            } label: {
                Image(systemName: "minus")
                    .padding()
            }
            .disabled(value == minValue)
            Button {
                if value != nil {
                    if value! > minValue {
                        value = value! - (increment * 0.5)
                    } else {
                        value = 0.0
                    }
                }
            } label: {
                Image(systemName: "minus")
                    .padding()
                    .font(.callout)
            }
            .disabled(value == minValue)
            Spacer()
            VStack {
                ClearOnTapValueField(value: $value, format: .number)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.center)
                    .font(.title2)
                Text(label)
                    .font(.caption)
                    .textCase(.uppercase)
            }
            Spacer()
            Button {
                if value != nil {
                    if value! < maxValue {
                        value = value! + (increment * 0.5)
                    } else {
                        value = 0.0
                    }
                }
            } label: {
                Image(systemName: "plus")
                    .padding()
                    .font(.callout)
            }
            .disabled(value == maxValue)
            Button {
                if value != nil {
                    if value! < maxValue {
                        value = value! + increment
                    } else {
                        value = 0.0
                    }
                }
            } label: {
                Image(systemName: "plus")
                    .padding()
            }
            .disabled(value == maxValue)

        }
        .padding(2)
        .background(Color.init(.systemGray6))
        .foregroundStyle(Color.primary)
        .font(.title2)
        .clipShape(
            RoundedRectangle(cornerRadius: 100)
        )
        .sensoryFeedback(trigger: value ?? 0.0) { oldValue, newValue in
            if oldValue > newValue {
                return .decrease
            } else {
                return .increase
            }
        }
    }
}

struct ClearOnTapValueField<Value, Format>: View
where Value: Equatable,
      Format: ParseableFormatStyle,
      Format.FormatInput == Value,
      Format.FormatOutput == String
{
    @Binding var value: Value?
    @State private var savedValue: Value?
    @State private var savedValueString: String?
    var format: Format
    var placeholder: String = ""
    
    @FocusState private var isFocused: Bool
    
    var body: some View {
        TextField(effectivePlaceholder, value: $value, format: format)
            .focused($isFocused)
            .onChange(of: isFocused) { oldFocusValue, newFocusValue in
                if newFocusValue {
                    if let value = value {
                        savedValue = value
                        savedValueString = format.format(value)
                    }
                    value = nil
                } else {
                    if value == nil {
                        value = savedValue
                    }
                    savedValue = nil
                }
            }
    }
    
    private var effectivePlaceholder: String {
        if let savedValueString = savedValueString {
            return savedValueString
        } else {
            return placeholder
        }
    }
}
