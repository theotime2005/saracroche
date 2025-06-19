import StoreKit
import SwiftUI

struct FullWidthButtonStyle: ButtonStyle {
  var backgroundColor: Color
  var foregroundColor: Color

  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .padding()
      .bold()
      .frame(maxWidth: .infinity)
      .background(backgroundColor)
      .foregroundColor(foregroundColor)
      .cornerRadius(16)
      .opacity(configuration.isPressed ? 0.8 : 1.0)
  }
}

extension ButtonStyle where Self == FullWidthButtonStyle {
  static func fullWidth(background: Color, foreground: Color)
    -> FullWidthButtonStyle
  {
    return FullWidthButtonStyle(
      backgroundColor: background,
      foregroundColor: foreground
    )
  }
}

struct SaracrocheView: View {
  @StateObject private var viewModel = SaracrocheViewModel()
  @State private var showDeleteConfirmation = false
  @Environment(\.requestReview) var requestReview

  var body: some View {
    TabView {
      HomeNavigationView(viewModel: viewModel)
        .tabItem {
          Label("Accueil", systemImage: "house.fill")
        }
      ReportNavigationView()
        .tabItem {
          Label("Signaler", systemImage: "exclamationmark.bubble.fill")
        }
      HelpNavigationView(requestReview: { requestReview() })
        .tabItem {
          Label("Aide", systemImage: "questionmark.circle.fill")
        }
      SettingsNavigationView(
        viewModel: viewModel,
        showDeleteConfirmation: $showDeleteConfirmation,
        requestReview: { requestReview() }
      )
      .tabItem {
        Label("Réglages", systemImage: "gearshape.fill")
      }
    }
    .sheet(isPresented: $viewModel.showBlockerStatusSheet) {
      BlockerStatusSheet(viewModel: viewModel)
        .interactiveDismissDisabled(true)
    }
  }
}

#Preview {
  SaracrocheView()
}
