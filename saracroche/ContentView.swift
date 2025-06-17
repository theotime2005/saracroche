import StoreKit
import SwiftUI

struct FullWidthButtonStyle: ButtonStyle {
  var backgroundColor: Color
  var foregroundColor: Color

  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .padding()
      .frame(maxWidth: .infinity)
      .background(backgroundColor)
      .foregroundColor(foregroundColor)
      .cornerRadius(16)
      .opacity(configuration.isPressed ? 0.8 : 1.0)
  }
}

extension ButtonStyle where Self == FullWidthButtonStyle {
  static func fullWidth(background: Color, foreground: Color) -> FullWidthButtonStyle {
    return FullWidthButtonStyle(backgroundColor: background, foregroundColor: foreground)
  }
}

struct ContentView: View {
  @StateObject private var viewModel = SaracrocheViewModel()
  @State private var showDeleteConfirmation = false
  @State private var showBlockerStatusSheet = false
  @Environment(\.requestReview) var requestReview

  var body: some View {
    TabView {
      // Onglet Accueil
      NavigationView {
        VStack {
          ScrollView {
            VStack {
              // Affichage du statut du bloqueur d'appels
              VStack(alignment: .center) {
                VStack {
                  if #available(iOS 18.0, *) {
                    Image(
                      systemName: viewModel.isBlockerEnabled
                        ? "checkmark.shield.fill" : "xmark.circle.fill"
                    )
                    .font(.system(size: 48))
                    .symbolEffect(.bounce.up.byLayer, options: .repeat(.periodic(delay: 1.0)))
                    .foregroundColor(viewModel.isBlockerEnabled ? .green : .red)
                  } else {
                    Image(
                      systemName: viewModel.isBlockerEnabled
                        ? "checkmark.shield.fill" : "xmark.circle.fill"
                    )
                    .font(.system(size: 48))
                    .foregroundColor(viewModel.isBlockerEnabled ? .green : .red)
                  }

                  Text(viewModel.blockerStatusMessage)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .padding(.top)
                }
                .padding(.vertical)

                if !viewModel.isBlockerEnabled {
                  Text(
                    "Pour activer le bloqueur d'appels, il suffit d'utiliser le bouton ci-dessous et de suivre les instructions pour l'activer dans les réglages de votre iPhone. Une fois l'activation effectuée, il sera possible d'installer la liste de blocage afin de filtrer les appels indésirables."
                  )
                  .font(.body)
                  .padding(.vertical)
                  .frame(maxWidth: .infinity, alignment: .center)

                  Button {
                    viewModel.openSettings()
                  } label: {
                    HStack {
                      Image(systemName: "gear")
                      Text("Activer dans les réglages")
                    }
                  }
                  .buttonStyle(.fullWidth(background: Color.red, foreground: .white))
                }
              }
              .padding()
              .frame(maxWidth: .infinity, alignment: .center)
              .background(
                RoundedRectangle(cornerRadius: 16)
                  .fill(
                    viewModel.isBlockerEnabled
                      ? Color.green.opacity(0.15)
                      : Color.red.opacity(0.15)
                  )
              )
              .overlay(
                RoundedRectangle(cornerRadius: 16)
                  .stroke(
                    viewModel.isBlockerEnabled
                      ? Color.green.opacity(0.5)
                      : Color.red.opacity(0.5),
                    lineWidth: 1
                  )
              )

              // Affichage du statut de la liste de blocage
              if viewModel.isBlockerEnabled {
                VStack {
                  if viewModel.blockerStatus == "update" {
                    HStack {
                      Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.yellow)
                      Text("Gardez l'application ouverte")
                        .bold()
                    }
                    .onAppear {
                      showBlockerStatusSheet = true
                    }
                  } else if viewModel.blockerStatus == "delete" {
                    HStack {
                      Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.yellow)
                      Text("Gardez l'application ouverte")
                        .bold()
                    }
                    .onAppear {
                      showBlockerStatusSheet = true
                    }
                  } else if viewModel.blockerStatus == "active" {
                    if viewModel.isUpdateAvailable {
                      Button {
                        viewModel.reloadBlockerListExtension()
                      } label: {
                        HStack {
                          Image(systemName: "arrow.counterclockwise.circle.fill")
                          Text("Mettre à jour la liste de blocage")
                        }
                      }
                      .buttonStyle(.fullWidth(background: Color.red, foreground: .white))
                    } else {
                      Text("La liste de blocage est à jour !")
                        .bold()
                    }
                  } else {
                    Image(
                      systemName: "exclamationmark.triangle.fill"
                    )
                    .font(.system(size: 48))
                    .foregroundColor(.gray)

                    Text("Aucune liste de blocage installée.")
                      .font(.title3)
                      .fontWeight(.semibold)
                      .padding(.top)

                    Text("Pour bloquer les appels indésirables, installez la liste de blocage.")
                      .font(.body)
                      .padding(.vertical)

                    Button {
                      viewModel.reloadBlockerListExtension()
                    } label: {
                      HStack {
                        Image(systemName: "arrow.down.square.fill")
                        Text("Installer la liste de blocage")
                      }
                    }
                    .buttonStyle(.fullWidth(background: Color.blue, foreground: .white))
                  }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                  RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.2))
                )
                .overlay(
                  RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                )
                .padding(.top)
              }
            }
            .padding()
          }
          Spacer()
        }
        .navigationTitle("Saracroche")
      }
      .tabItem {
        Label("Accueil", systemImage: "house.fill")
      }

      // Onglet Signaler
      NavigationView {
        ScrollView {
          VStack {
            GroupBox(
              label:
                Label(
                  "Améliorer la liste de blocage",
                  systemImage: "exclamationmark.shield.fill"
                )
            ) {
              Text(
                "Dans le but d'améliorer le blocage des appels et SMS indésirables, il est possible de signaler les numéros qui ne sont pas bloqués par l'application. Cela contribuera à établir une liste de blocage et à rendre l'application plus efficace. Pour l'instant le signalement se fait par email."
              )
              .font(.body)
              .padding(.top, 4)
              .frame(maxWidth: .infinity, alignment: .leading)
            }

            Button {
              if let url = URL(string: "mailto:saracroche@cbouvat.com?subject=Signalement numéro") {
                UIApplication.shared.open(url)
              }
            } label: {
              HStack {
                Image(systemName: "envelope.fill")
                Text("Signaler un numéro")
              }
            }
            .buttonStyle(.fullWidth(background: Color("AccentColor"), foreground: .black))
            .padding(.top)

          }
          .padding()
        }
        .navigationTitle("Signaler")
      }
      .tabItem {
        Label("Signaler", systemImage: "exclamationmark.bubble.fill")
      }

      // Onglet Aide
      NavigationStack {
        ScrollView {
          VStack {
            GroupBox(
              label:
                Label(
                  "Quels numéros sont bloqués ?",
                  systemImage: "questionmark.circle.fill"
                )
            ) {
              Text(
                "L'application bloque les préfixes suivants, communiqués par l'ARCEP : 0162, 0163, 0270, 0271, 0377, 0378, 0424, 0425, 0568, 0569, 0948, 0949, ainsi que ceux allant de 09475 à 09479. Ces préfixes sont réservés au démarchage téléphonique."
              )
              .font(.body)
              .padding(.top, 4)
              .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.bottom)

            GroupBox(
              label:
                Label(
                  "Comment fonctionne l'application ?",
                  systemImage: "info.circle.fill"
                )
            ) {
              Text(
                "L'application utilise une extension de blocage d'appels et de SMS fournis par système pour filtrer les numéros indésirables. Elle est conçue pour être simple et efficace, sans nécessiter de configuration complexe."
              )
              .font(.body)
              .padding(.top, 4)
              .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.bottom)

            GroupBox(
              label:
                Label(
                  "Comment signaler un numéro ?",
                  systemImage: "exclamationmark.shield.fill"
                )
            ) {
              Text(
                "Pour signaler un numéro indésirable, vous pouvez utiliser le bouton 'Signaler' dans l'onglet 'Signaler'. Cela aidera à améliorer la liste de blocage et à rendre l'application plus efficace."
              )
              .font(.body)
              .padding(.top, 4)
              .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.bottom)

            GroupBox(
              label:
                Label(
                  "Pourquoi les numéros bloqués apparaissent-ils dans l'historique des appels ?",
                  systemImage: "clock.fill"
                )
            ) {
              Text(
                "Depuis iOS 18, les numéros bloqués par les extensions de blocage d'appels sont visibles dans l'historique des appels. Cela permet de garder une trace des appels bloqués, mais ne signifie pas que l'appel a été reçu ou que vous devez y répondre."
              )
              .font(.body)
              .padding(.top, 4)
              .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.bottom)

            GroupBox(
              label:
                Label(
                  "Comment participer au projet ?",
                  systemImage: "gift.fill"
                )
            ) {
              Text(
                "L'application Saracroche est open source et développée bénévolement. Un soutien au projet est possible. Cette aide est précieuse pour maintenir et améliorer l'application."
              )
              .font(.body)
              .padding(.top, 4)
              .frame(maxWidth: .infinity, alignment: .leading)

              Button {
                if let url = URL(string: "https://github.com/sponsors/cbouvat") {
                  UIApplication.shared.open(url)
                }
              } label: {
                HStack {
                  Image(systemName: "heart.fill")
                  Text("Soutenir le projet sur GitHub")
                }
              }
              .font(.body)
              .padding(.top, 4)
              .frame(maxWidth: .infinity, alignment: .leading)

              Button {
                if let url = URL(string: "https://liberapay.com/cbouvat") {
                  UIApplication.shared.open(url)
                }
              } label: {
                HStack {
                  Image(systemName: "heart.fill")
                  Text("Soutenir le projet sur Liberapay")
                }
              }
              .font(.body)
              .padding(.top, 4)
              .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.bottom)

            GroupBox(
              label:
                Label(
                  "Comment noter l'application ?",
                  systemImage: "star.fill"
                )
            ) {
              Text(
                "Si l'application Saracroche vous est utile, une évaluation sur l'App Store serait appréciée. Ce soutien aide à atteindre davantage de personnes utilisatrices et à améliorer continuellement l'application."
              )
              .font(.body)
              .padding(.top, 4)
              .frame(maxWidth: .infinity, alignment: .leading)

              Button {
                requestReview()
              } label: {
                HStack {
                  Image(systemName: "star.fill")
                  Text("Noter l'application")
                }
              }
              .font(.body)
              .padding(.top, 4)
              .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.bottom)

            GroupBox(
              label:
                Label(
                  "Comment signaler un bug ?",
                  systemImage: "ladybug.fill"
                )
            ) {
              Text(
                "En cas de bug ou de problème avec l'application, merci de le signaler sur GitHub ou par email."
              )
              .font(.body)
              .padding(.top, 4)
              .frame(maxWidth: .infinity, alignment: .leading)

              Button {
                if let url = URL(string: "https://github.com/cbouvat/saracroche/issues") {
                  UIApplication.shared.open(url)
                }
              } label: {
                HStack {
                  Image(systemName: "chevron.left.slash.chevron.right")
                  Text("Signaler un bug sur GitHub")
                }
              }
              .font(.body)
              .padding(.top, 4)
              .frame(maxWidth: .infinity, alignment: .leading)

              Button {
                if let url = URL(string: "mailto:saracroche@cbouvat.com?subject=Signalement bug") {
                  UIApplication.shared.open(url)
                }
              } label: {
                HStack {
                  Image(systemName: "envelope.fill")
                  Text("Envoyer un email")
                }
              }
              .font(.body)
              .padding(.top, 4)
              .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.bottom)

            GroupBox(
              label:
                Label(
                  "Pourquoi l'application est-elle gratuite ?",
                  systemImage: "dollarsign.circle.fill"
                )
            ) {
              Text(
                "L'application Saracroche est gratuite et sans publicité. Elle est développée bénévolement par un développeur indépendant (Camille), qui en avait assez de recevoir des appels indésirables. L'application est développée sur son temps libre. Vous pouvez soutenir le projet en faisant un don sur GitHub ou Liberapay."
              )
              .font(.body)
              .padding(.top, 4)
              .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.bottom)

            Text(
              "Bisous 😘"
            )
            .font(.footnote)
            .padding(.top)
            .frame(maxWidth: .infinity, alignment: .center)
          }
          .padding()
          .frame(maxWidth: .infinity, alignment: .center)
        }
        .navigationTitle("Aide")
      }
      .tabItem {
        Label("Aide", systemImage: "questionmark.circle.fill")
      }

      // Onglet Réglages
      NavigationView {
        Form {
          Section(header: Text("Extension de blocage")) {
            Button {
              viewModel.openSettings()
            } label: {
              Label(
                "L’extension de blocage dans Réglages",
                systemImage: "gear")
            }
          }

          Section(header: Text("Liste de blocage")) {
            Button(role: .destructive) {
              showDeleteConfirmation = true
            } label: {
              Label(
                "Supprimer la liste de blocage",
                systemImage: "trash.fill"
              )
            }
            .confirmationDialog(
              "Supprimer la liste de blocage",
              isPresented: $showDeleteConfirmation,
              titleVisibility: .visible
            ) {
              Button("Supprimer", role: .destructive) {
                viewModel.removeBlockerList()
              }
            } message: {
              Text("Êtes-vous sûr de vouloir supprimer la liste de blocage ?")
            }

            Button {
              viewModel.reloadBlockerListExtension()
            } label: {
              Label(
                "Recharger la liste de blocage",
                systemImage: "arrow.counterclockwise.circle.fill"
              )
            }
          }

          Section(header: Text("Liens utiles")) {
            Button {
              if let url = URL(string: "https://github.com/cbouvat/saracroche") {
                UIApplication.shared.open(url)
              }
            } label: {
              Label("Code source sur GitHub", systemImage: "chevron.left.slash.chevron.right")
            }
            Button {
              if let url = URL(string: "https://cbouvat.com/saracroche") {
                UIApplication.shared.open(url)
              }
            } label: {
              Label("Site officiel", systemImage: "safari")
            }
            Button {
              if let url = URL(string: "https://mastodon.social/@cbouvat") {
                UIApplication.shared.open(url)
              }
            } label: {
              Label("Mastodon : @cbouvat", systemImage: "at")
            }
          }

          Section(header: Text("Application")) {
            Button {
              requestReview()
            } label: {
              Label("Noter l'application", systemImage: "star.fill")
            }
          }
        }
        .navigationTitle("Réglages")
      }
      .tabItem {
        Label("Réglages", systemImage: "gearshape.fill")
      }
    }
    .sheet(isPresented: $showBlockerStatusSheet) {
      VStack(spacing: 24) {
        Text("Garder l’application ouverte")
          .font(.title)
          .fontWeight(.bold)
          .multilineTextAlignment(.center)

        if #available(iOS 18.0, *) {
          Image(systemName: "gearshape.arrow.trianglehead.2.clockwise.rotate.90")
          .font(.system(size: 100))
          .symbolEffect(.rotate.byLayer, options: .repeat(.continuous))
          .foregroundColor(Color("AccentColor"))
          .padding(.top)
        } else {
          Image(systemName: "gearshape.arrow.trianglehead.2.clockwise.rotate.90")
          .font(.system(size: 100))
          .foregroundColor(Color("AccentColor"))
          .padding(.top)
        }

        if viewModel.blockerStatus == "update" {
          Text("Mise à jour de la liste de blocage")
            .font(.title2)
            .fontWeight(.bold)
        } else if viewModel.blockerStatus == "delete" {
          Text("Suppression de la liste de blocage")
            .font(.title2)
            .fontWeight(.bold)
        } 
        
        
        if !viewModel.blockerUpdateStatusMessage.isEmpty {
          Text(viewModel.blockerUpdateStatusMessage)
            .font(.title3)
            .fontWeight(.bold)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
            .padding(.top)
        }
        Button("Fermer") {
          showBlockerStatusSheet = false
        }
        .padding(.top)
      }
      .padding()
    }
  }
}

#Preview {
  ContentView()
}
