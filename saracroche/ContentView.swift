import SwiftUI
import StoreKit

struct ContentView: View {
  @StateObject private var viewModel = SaracrocheViewModel()
  @State private var showDeleteConfirmation = false
  @State private var showInfoSheet = false
  @Environment(\.requestReview) var requestReview

  var body: some View {
    ScrollView {
      VStack {
        Text("Saracroche")
          .font(.largeTitle)
          .fontWeight(.heavy)
          .foregroundColor(Color("AccentColor"))
          .frame(maxWidth: .infinity, alignment: .leading)

        VStack(alignment: .center) {
          Text("Statut du bloqueur d'appels et SMS")
            .font(.title3)
            .fontWeight(.semibold)
            .multilineTextAlignment(.center)

          HStack {
            Image(
              systemName: viewModel.isBlockerEnabled ? "checkmark.circle.fill" : "xmark.circle.fill"
            )
            .foregroundColor(viewModel.isBlockerEnabled ? .green : .red)
            Text(viewModel.blockerStatusMessage)
          }
          .padding(.top)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .center)
        .background(
          RoundedRectangle(cornerRadius: 16)
            .fill(Color("AccentColor").opacity(0.2))
        )
        .overlay(
          RoundedRectangle(cornerRadius: 16)
            .stroke(Color("AccentColor"), lineWidth: 1)
        )

        VStack {
          if !viewModel.isBlockerEnabled {
            Text("Le bloqueur d'appels n'est pas activé")
              .font(.title3)
              .fontWeight(.semibold)
              .padding(.bottom)
              .multilineTextAlignment(.center)
              .frame(maxWidth: .infinity, alignment: .center)

            Text(
              "Pour activer le bloqueur d'appels, il suffit d'utiliser le bouton ci-dessous et de suivre les instructions pour l'activer dans les réglages de votre iPhone. Une fois l'activation effectuée, il sera possible d'installer la liste de blocage afin de filtrer les appels indésirables."
            )
            .font(.footnote)
            .padding(.bottom)
            .frame(maxWidth: .infinity, alignment: .center)

            Button("Activer dans les réglages") {
              viewModel.openSettings()
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
            .overlay(
              HStack {
                Image(systemName: "shield.fill")
                  .padding(.leading)
                Spacer()
              }
            )
          } else {
            Text("Statut de la liste de blocage")
              .font(.title3)
              .fontWeight(.semibold)
              .padding(.bottom)

            Text("\(viewModel.blockerUpdateStatusMessage)")
              .font(.footnote)
              .multilineTextAlignment(.center)
              .padding(.bottom)

            if viewModel.blockerStatus == "update" {
              Text("⚠️ Gardez l'application ouverte.")
                .bold()
            } else if viewModel.blockerStatus == "delete" {
              Text("⚠️ Gardez l'application ouverte.")
                .bold()
            } else if viewModel.blockerStatus == "active" {
              if viewModel.isUpdateAvailable {
                Button {
                  viewModel.reloadBlockerListExtension()
                } label: {
                  HStack {
                    Image(systemName: "arrow.clockwise")
                    Text("Mettre à jour la liste de blocage")
                  }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(8)
              } else {
                Text("La liste de blocage est à jour !")
                  .bold()
                Button {
                  viewModel.reloadBlockerListExtension()
                } label: {
                  HStack {
                    Image(systemName: "arrow.triangle.2.circlepath")
                    Text("Recharger la liste de blocage")
                  }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(8)
              }
              Button {
                showDeleteConfirmation = true
              } label: {
                HStack {
                  Image(systemName: "trash")
                  Text("Supprimer la liste de blocage")
                }
              }
              .padding()
              .frame(maxWidth: .infinity)
              .background(Color.red)
              .foregroundColor(.white)
              .cornerRadius(8)
              .confirmationDialog(
                "Supprimer la liste de blocage",
                isPresented: $showDeleteConfirmation,
                titleVisibility: .visible
              ) {
                Button("Supprimer", role: .destructive) {
                  viewModel.removeBlockerList()
                }
              } message: {
                Text(
                  "Êtes-vous sûr de vouloir supprimer la liste de blocage ?"
                )
              }
            } else {
              Button {
                viewModel.reloadBlockerListExtension()
              } label: {
                HStack {
                  Image(systemName: "square.and.arrow.down")
                  Text("Installer la liste de blocage")
                }
              }
              .padding()
              .frame(maxWidth: .infinity)
              .background(Color.blue)
              .foregroundColor(.white)
              .cornerRadius(8)
            }
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

        Button {
          showInfoSheet = true
        } label: {
          HStack {
            Image(systemName: "info.circle")
            Text("À propos de Saracroche")
          }
        }
        .padding()
        .bold()
        .frame(maxWidth: .infinity)
        .background(Color("AccentColor"))
        .foregroundColor(.black)
        .cornerRadius(8)
        .padding(.top)
      }
      .padding()
    }
    .sheet(isPresented: $showInfoSheet) {
      NavigationStack {
        ScrollView {
          VStack(alignment: .leading) {
            Group {
              HStack {
                Image(systemName: "exclamationmark.shield")
                  .foregroundColor(.blue)
                Text("Améliorez le blocage")
                  .font(.headline)
              }
              Text(
                "Dans le but d'améliorer le blocage des appels et SMS indésirables, il est possible de signaler les numéros qui ne sont pas bloqués par l'application. Cela contribuera à enrichir la liste de blocage et à rendre l'application plus efficace. Pour cela, il suffit d'envoyer un email à l'adresse suivante : saracroche@cbouvat.com"
              )
              .font(.footnote)
            }
            .padding(.bottom)

            Group {
              HStack {
                Image(systemName: "questionmark.circle")
                  .foregroundColor(.blue)
                Text("Information sur les numéros bloqués")
                  .font(.headline)
              }

              Text(
                "L'application bloque les préfixes suivants, communiqués par l'ARCEP : 0162, 0163, 0270, 0271, 0377, 0378, 0424, 0425, 0568, 0569, 0948, 0949, ainsi que ceux allant de 09475 à 09479. Ces préfixes sont réservés au démarchage téléphonique."
              )
              .font(.footnote)
            }
            .padding(.bottom)

            Group {
              HStack {
                Image(systemName: "gift")
                  .foregroundColor(.blue)
                Text("Aidez au développement")
                  .font(.headline)
              }

              Text(
                "L'application Saracroche est open source et développée bénévolement. Un soutien au projet est possible via [GitHub Sponsors](https://github.com/sponsors/cbouvat). Cette aide est précieuse pour maintenir et améliorer l'application."
              )
              .font(.footnote)
            }
            .padding(.bottom)

            Group {
              HStack {
                Image(systemName: "star")
                  .foregroundColor(.yellow)
                Text("Notez l'application sur l'App Store")
                  .font(.headline)
              }

              Text(
                "Si l'application Saracroche vous est utile, une évaluation sur l'App Store serait appréciée. Ce soutien aide à atteindre davantage de personnes utilisatrices et à améliorer continuellement l'application."
              )
              .font(.footnote)
              Button {
                requestReview()
              } label: {
                HStack {
                  Image(systemName: "star.fill")
                  Text("Noter l'application")
                }
              }
              .font(.footnote)
            }
            .padding(.bottom)

            Group {
              HStack {
                Image(systemName: "ladybug")
                  .foregroundColor(.red)
                Text("Signaler un bug")
                  .font(.headline)
              }

              Text(
                "En cas de bug ou de problème avec l'application, merci de le signaler sur [GitHub](https://github.com/cbouvat/saracroche/issues) ou par email à l'adresse suivante : saracroche@cbouvat.com"
              )
              .font(.footnote)
            }
            .padding(.bottom)

            Group {
              HStack {
                Image(systemName: "link")
                  .foregroundColor(.blue)
                Text("Liens utiles")
                  .font(.headline)
              }

              Text(
                "Code source de l'application : [GitHub](https://github.com/cbouvat/saracroche)\nLe site officiel de l'application : [cbouvat.com/saracroche](https://cbouvat.com/saracroche)\nSuivez-moi sur Mastodon : [@cbouvat](https://mastodon.social/@cbouvat)\n\nBisous 😘"
              )
              .font(.footnote)
            }
            .padding(.bottom)
          }
          .padding()
        }
        .navigationTitle("À propos de Saracroche")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
          ToolbarItem(placement: .confirmationAction) {
            Button("Fermer") {
              showInfoSheet = false
            }
          }
        }
      }
    }
  }
}

#Preview {
  ContentView()
}
