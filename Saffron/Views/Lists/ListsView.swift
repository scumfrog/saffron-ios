import SwiftUI
import SwiftData

struct ListsView: View {
    @Environment(AppTheme.self) private var theme
    @Query(sort: \RecipeList.createdAt) private var lists: [RecipeList]
    @Environment(\.modelContext) private var context
    @State private var showNewList = false
    @State private var newListName = ""
    @State private var selectedList: RecipeList?

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Lists")
                            .font(.system(size: 34, weight: .bold))
                        Text("Organize by moment or taste")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 6)
                    .padding(.bottom, 18)

                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(lists) { list in
                            NavigationLink(value: list) {
                                ListCardView(list: list)
                            }
                            .buttonStyle(.plain)
                        }

                        // New list card
                        Button { showNewList = true } label: {
                            VStack(spacing: 10) {
                                Image(systemName: "plus")
                                    .font(.system(size: 22, weight: .semibold))
                                    .foregroundStyle(theme.accent)
                                Text("New list")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundStyle(theme.accent)
                            }
                            .frame(maxWidth: .infinity, minHeight: 120)
                            .overlay(
                                RoundedRectangle(cornerRadius: 18)
                                    .stroke(style: StrokeStyle(lineWidth: 1.5, dash: [5]))
                                    .foregroundStyle(.quaternary)
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 120)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarHidden(true)
            .navigationDestination(for: RecipeList.self) { list in
                ListDetailView(list: list)
            }
            .alert("New list", isPresented: $showNewList) {
                TextField("Name", text: $newListName)
                Button("Cancel", role: .cancel) { newListName = "" }
                Button("Create") { createList() }
            }
        }
    }

    private func createList() {
        guard !newListName.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        let list = RecipeList(name: newListName)
        context.insert(list)
        newListName = ""
    }
}

struct ListCardView: View {
    let list: RecipeList
    @Environment(\.modelContext) private var context
    @State private var showDeleteConfirm = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(list.color.opacity(0.18))
                    .frame(width: 38, height: 38)
                Image(systemName: list.icon)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(list.color)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(list.name)
                    .font(.system(size: 15, weight: .semibold))
                    .tracking(-0.2)
                    .lineLimit(2)
                Text("\((list.recipes ?? []).count) recipes")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 0)
        }
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: 120, alignment: .topLeading)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .contentShape(Rectangle())
        .contextMenu {
            Button(role: .destructive) {
                showDeleteConfirm = true
            } label: {
                Label("Delete list", systemImage: "trash")
            }
        }
        .confirmationDialog("Delete list?", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                context.delete(list)
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will remove the list. Recipes won't be deleted.")
        }
    }
}
