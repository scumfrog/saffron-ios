import SwiftUI
import SwiftData

struct AddToListView: View {
    let recipe: Recipe
    @Environment(AppTheme.self) private var theme
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \RecipeList.name) private var lists: [RecipeList]

    @State private var showNewList = false
    @State private var newListName = ""

    var body: some View {
        NavigationStack {
            Group {
                if lists.isEmpty {
                    emptyState
                } else {
                    List(lists) { list in
                        Button { toggle(list) } label: {
                            HStack(spacing: 12) {
                                Text(list.icon)
                                    .font(.title2)
                                Text(list.name)
                                    .foregroundStyle(.primary)
                                    .font(.system(size: 16))
                                Spacer()
                                if isInList(list) {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundStyle(theme.accent)
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Add to list")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showNewList = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .alert("New list", isPresented: $showNewList) {
                TextField("List name", text: $newListName)
                Button("Create") { createList() }
                    .disabled(newListName.trimmingCharacters(in: .whitespaces).isEmpty)
                Button("Cancel", role: .cancel) { newListName = "" }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "square.grid.2x2")
                .font(.system(size: 40))
                .foregroundStyle(.quaternary)
            Text("No lists yet")
                .font(.headline)
            Text("Tap + to create your first list.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func isInList(_ list: RecipeList) -> Bool {
        (list.recipes ?? []).contains { $0.id == recipe.id }
    }

    private func toggle(_ list: RecipeList) {
        if let idx = (list.recipes ?? []).firstIndex(where: { $0.id == recipe.id }) {
            list.recipes?.remove(at: idx)
        } else {
            list.recipes?.append(recipe)
        }
        try? context.save()
    }

    private func createList() {
        let name = newListName.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty else { return }
        let list = RecipeList(name: name)
        context.insert(list)
        list.recipes = [recipe]
        try? context.save()
        newListName = ""
    }
}
