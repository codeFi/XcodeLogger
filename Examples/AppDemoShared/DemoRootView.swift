//
//  DemoRootView.swift
//  XcodeLogger
//
/*
 *  Created by Razvan Tanase on 15/06/26.
 *  Copyright (c) 2026 Codebringers Software SRL. All rights reserved.
 *
 *  Permission is hereby granted, free of charge, to any person obtaining a copy
 *  of this software and associated documentation files (the "Software"), to deal
 *  in the Software without restriction, including without limitation the rights
 *  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 *  copies of the Software, and to permit persons to whom the Software is
 *  furnished to do so, subject to the following conditions:
 *
 *  The above copyright notice and this permission notice shall be included in
 *  all copies or substantial portions of the Software.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 *  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 *  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 *  THE SOFTWARE.
 *
 */// Project's Source: https://github.com/codeFi/XcodeLogger

import SwiftUI
import XcodeLogger

struct DemoRootView: View {
    @StateObject private var viewModel: DemoViewModel
    private let platformNote: String

    init(subsystem: String, platformNote: String) {
        _viewModel = StateObject(wrappedValue: DemoViewModel(subsystem: subsystem))
        self.platformNote = platformNote
    }

    var body: some View {
#if os(macOS)
        NavigationSplitView {
            List(viewModel.scenarioDefinitions, id: \.id, selection: $viewModel.selectedScenario) { definition in
                VStack(alignment: .leading, spacing: 4) {
                    Text(definition.title)
                    Text(definition.summary)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .tag(definition.id)
            }
            .navigationTitle("Scenarios")
        } detail: {
            detailContent
        }
#else
        NavigationStack {
            List {
                Section("Scenario") {
                    Picker("Scenario", selection: $viewModel.selectedScenario) {
                        ForEach(viewModel.scenarioDefinitions, id: \.id) { definition in
                            Text(definition.title).tag(definition.id)
                        }
                    }
                    .pickerStyle(.navigationLink)

                    Text(DemoScenarioCatalog.definition(for: viewModel.selectedScenario).summary)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Section("Controls") {
                    controls
                }

                Section("Output") {
                    outputPanel
                }
            }
            .navigationTitle("XcodeLogger iOS Demo")
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button("Run") { viewModel.runSelectedScenario() }
                    Button("Run All") { viewModel.runAll() }
                }
            }
        }
#endif
    }

    @ViewBuilder
    private var detailContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(DemoScenarioCatalog.definition(for: viewModel.selectedScenario).title)
                .font(.largeTitle.weight(.semibold))
            Text(DemoScenarioCatalog.definition(for: viewModel.selectedScenario).summary)
                .foregroundStyle(.secondary)

            controls

            HStack {
                Button("Run Scenario") { viewModel.runSelectedScenario() }
                Button("Run All") { viewModel.runAll() }
            }

            outputPanel
        }
        .padding()
    }

    private var controls: some View {
        VStack(alignment: .leading, spacing: 12) {
            Picker("Theme", selection: $viewModel.selectedTheme) {
                ForEach(DemoThemeChoice.allCases, id: \.self) { theme in
                    Text(theme.title).tag(theme)
                }
            }

            Picker("Minimum Level", selection: $viewModel.minimumLevel) {
                ForEach(LoggerLevel.allCases, id: \.self) { level in
                    Text(String(describing: level)).tag(level)
                }
            }

            Picker("Sink", selection: $viewModel.sinkMode) {
                ForEach(DemoSinkMode.allCases, id: \.self) { mode in
                    Text(mode.title).tag(mode)
                }
            }

            Toggle("ANSI Enabled", isOn: $viewModel.ansiEnabled)

            VStack(alignment: .leading, spacing: 8) {
                Text("Enabled Categories")
                    .font(.headline)
                ForEach(DemoScenarioCatalog.categories, id: \.rawValue) { category in
                    Toggle(
                        category.rawValue,
                        isOn: Binding(
                            get: { viewModel.enabledCategoryNames.contains(category.rawValue) },
                            set: { _ in viewModel.toggleCategory(category) }
                        )
                    )
                }
                Text("Current filter: \(viewModel.enabledCategoriesSummary)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Text(platformNote)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }

    private var outputPanel: some View {
        VStack(alignment: .leading, spacing: 8) {
            if !viewModel.capturePath.isEmpty {
                Text("Captured debug sink: \(viewModel.capturePath)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            ScrollView {
                Text(viewModel.output)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .textSelection(.enabled)
                    .font(.system(.body, design: .monospaced))
                    .padding(12)
            }
            .background(.quaternary.opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}
