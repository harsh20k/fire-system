import SwiftUI

/// Pages-style education hub: sidebar page picker + detail content.
struct EducationView: View {
    @Environment(\.colorScheme) private var scheme
    @Environment(AppStore.self) private var store

    @State private var selectedPageID: String?
    @State private var columnVisibility: NavigationSplitViewVisibility = .all
    @State private var searchText = ""

    private var pages: [EducationPageData] { EducationContentProvider.pages }

    private var filteredPages: [EducationPageData] {
        guard !searchText.isEmpty else { return pages }
        return pages.filter {
            $0.title.localizedCaseInsensitiveContains(searchText)
                || $0.subtitle.localizedCaseInsensitiveContains(searchText)
        }
    }

    private var selectedPage: EducationPageData? {
        guard let id = selectedPageID else { return pages.first }
        return pages.first { $0.id == id } ?? pages.first
    }

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            sidebar
        } detail: {
            if let page = selectedPage {
                EducationPageDetailView(page: page, annualExpenses: store.inputs.annualExpenses)
            } else {
                ContentUnavailableView("Select a Page", systemImage: "book.fill", description: Text("Choose a topic from the sidebar."))
            }
        }
        .onAppear {
            if selectedPageID == nil { selectedPageID = pages.first?.id }
        }
    }

    // MARK: - Sidebar

    private var sidebar: some View {
        List(selection: $selectedPageID) {
            Section {
                VStack(alignment: .leading, spacing: 6) {
                    BrutalText(text: "Education", variant: .title, bold: true)
                    BrutalText(
                        text: "\(EducationContentProvider.pageCount) pages · \(EducationContentProvider.chartCount) charts",
                        variant: .caption,
                        color: Theme.mutedText(scheme)
                    )
                }
                .padding(.vertical, 8)
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            }

            Section("Topics") {
                ForEach(filteredPages) { page in
                    NavigationLink(value: page.id) {
                        HStack(spacing: 10) {
                            Image(systemName: page.icon)
                                .foregroundStyle(page.accent)
                                .frame(width: 20)
                            VStack(alignment: .leading, spacing: 2) {
                                BrutalText(text: "\(page.number) · \(page.title)", variant: .body, bold: true)
                                BrutalText(text: "\(page.sectionCount) sections", variant: .caption, color: Theme.mutedText(scheme))
                            }
                        }
                    }
                    .tag(page.id)
                }
            }
        }
        .searchable(text: $searchText, prompt: "Search topics")
        .navigationSplitViewColumnWidth(min: 220, ideal: Theme.sidebarWidth, max: 320)
        .navigationTitle("Education")
    }
}

#Preview {
    EducationView()
        .environment(AppStore())
}
