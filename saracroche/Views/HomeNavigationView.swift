import SwiftUI

struct HomeNavigationView: View {
  @ObservedObject var viewModel: SaracrocheViewModel
  var body: some View {
    NavigationView {
      VStack {
        ScrollView {
          VStack {
            // Affichage du statut du bloqueur d'appels
            VStack(alignment: .center) {
              VStack {
                if #available(iOS 18.0, *) {
                  Image(
                    systemName: viewModel.blockerExtensionStatus == .enabled
                      ? "checkmark.shield.fill" : "xmark.circle.fill"
                  )
                  .font(.system(size: 48))
                  .symbolEffect(.bounce.up.byLayer, options: .repeat(.periodic(delay: 1.0)))
                  .foregroundColor(viewModel.blockerExtensionStatus == .enabled ? .green : .red)
                  .padding(.bottom)
                } else {
                  Image(
                    systemName: viewModel.blockerExtensionStatus == .enabled
                      ? "checkmark.shield.fill" : "xmark.circle.fill"
                  )
                  .font(.system(size: 48))
                  .foregroundColor(viewModel.blockerExtensionStatus == .enabled ? .green : .red)
                  .padding(.bottom)
                }

                switch viewModel.blockerExtensionStatus {
                case .enabled:
                  Text("Le bloqueur d'appels est actif")
                    .font(.title3)
                    .bold()
                case .disabled:
                  Text("Le bloqueur d'appels n'est pas activé")
                    .font(.title3)
                    .bold()
                case .unknown:
                  Text("Statut inconnu")
                    .font(.title3)
                    .bold()
                case .error:
                  Text("Erreur")
                    .font(.title3)
                    .bold()
                case .unexpected:
                  Text("Statut inattendu")
                    .font(.title3)
                    .bold()
                }
              }
              .padding(.vertical)

              if viewModel.blockerExtensionStatus != .enabled {
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
                  viewModel.blockerExtensionStatus == .enabled
                    ? Color.green.opacity(0.15)
                    : Color.red.opacity(0.15)
                )
            )
            .overlay(
              RoundedRectangle(cornerRadius: 16)
                .stroke(
                  viewModel.blockerExtensionStatus == .enabled
                    ? Color.green.opacity(0.5)
                    : Color.red.opacity(0.5),
                  lineWidth: 1
                )
            )

            // Affichage du statut de la liste de blocage
            if viewModel.blockerExtensionStatus == .enabled
              && viewModel.blockerActionState == .nothing
            {
              VStack {
                if viewModel.blockerPhoneNumberBlocked == 0 {
                  Image(
                    systemName: "exclamationmark.triangle.fill"
                  )
                  .font(.system(size: 48))
                  .foregroundColor(.gray)

                  Text("Aucun numéro bloqué")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .padding(.top)

                  Text(
                    "Pour bloquer les appels indésirables, installez la liste de blocage qui contient les numéros à bloquer."
                  )
                  .multilineTextAlignment(.center)
                  .font(.body)
                  .padding(.vertical)

                  Button {
                    viewModel.updateBlockerList()
                  } label: {
                    HStack {
                      Image(systemName: "arrow.down.square.fill")
                      Text("Installer la liste de blocage")
                    }
                  }
                  .buttonStyle(.fullWidth(background: Color.blue, foreground: .white))
                } else if viewModel.blocklistVersion != viewModel.blocklistInstalledVersion {
                  Image(
                    systemName: "arrow.clockwise.circle.fill"
                  )
                  .font(.system(size: 48))
                  .foregroundColor(.orange)

                  Text("Mise à jour disponible")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .padding(.top)

                  Text(
                    "Une nouvelle version de la liste de blocage est disponible. Vous pouvez l'installer pour bloquer de nouveaux numéros indésirables."
                  )
                  .multilineTextAlignment(.center)
                  .font(.body)
                  .padding(.top)

                  Text(
                    "Version installée : \(viewModel.blocklistInstalledVersion), version disponible : \(viewModel.blocklistVersion)"
                  )
                  .font(.footnote)
                  .padding(.vertical)

                  Button {
                    viewModel.updateBlockerList()
                  } label: {
                    HStack {
                      Image(systemName: "arrow.counterclockwise.circle.fill")
                      Text("Mettre à jour la liste de blocage")
                    }
                  }
                  .buttonStyle(.fullWidth(background: Color.red, foreground: .white))
                } else if viewModel.blockerPhoneNumberBlocked != viewModel.blockerPhoneNumberTotal {
                  Image(
                    systemName: "exclamationmark.triangle.fill"
                  )
                  .font(.system(size: 48))
                  .foregroundColor(.orange)

                  Text("Liste de blocage partiellement installée")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .padding(.top)

                  Text("\(viewModel.blockerPhoneNumberBlocked) numéros bloqués sur \(viewModel.blockerPhoneNumberTotal)")
                    .font(.body)
                    .padding(.vertical)
                    .multilineTextAlignment(.center)

                  Button {
                    viewModel.updateBlockerList()
                  } label: {
                    HStack {
                      Image(systemName: "arrow.down.square.fill")
                      Text("Mettre à jour la liste de blocage")
                    }
                  }
                  .buttonStyle(.fullWidth(background: Color.red, foreground: .white))
                } else {
                  Image(
                    systemName: "checklist.checked"
                  )
                  .font(.system(size: 48))
                  .foregroundColor(.green)

                  Text(
                    "\(viewModel.blockerPhoneNumberBlocked) numéros bloqués"
                  )
                  .font(.title3)
                  .fontWeight(.semibold)
                  .padding(.top)

                  Text("Version de la liste de blocage : \(viewModel.blocklistVersion)")
                    .font(.footnote)
                    .padding(.top, 2)
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
  }
}
