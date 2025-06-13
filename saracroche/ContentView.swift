//
//  ContentView.swift
//  saracroche
//

import SwiftUI

struct ContentView: View {
  @StateObject private var viewModel = SaracrocheViewModel()

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

            Text(
              "Pour activer le bloqueur d'appels, cliquez sur le bouton ci-dessous et suivez les instructions pour l'activer dans les réglages de votre iPhone. Une fois activé, vous pourrez installer la liste de blocage pour filtrer les appels indésirables."
            )
            .font(.footnote)
            .padding(.bottom)

            Button("Activer dans les réglages") {
              viewModel.openSettings()
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
          } else {
            Text("Statut de la liste de blocage")
              .font(.title3)
              .fontWeight(.semibold)
              .padding(.bottom)

            Text("\(viewModel.blockerUpdateStatusMessage)")
              .font(.footnote)
              .padding(.bottom)

            if viewModel.blockerStatus == "update" {
              Text("⚠️ Gardez l'application ouverte pendant l'installation de la liste de blocage.")
                .bold()
                
            } else if viewModel.blockerStatus == "delete" {
              Text("⚠️ Gardez l'application ouverte pendant l'installation de la liste de blocage.")
                .bold()
            } else if viewModel.blockerStatus == "active" {
              if viewModel.isUpdateAvailable {
                Button("Mettre à jour la liste de blocage") {
                  viewModel.reloadBlockerListExtension()
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(8)
              } else {
                Text("La liste de blocage est à jour !")
                  .bold()
                Button("Recharger la liste de blocage") {
                  viewModel.reloadBlockerListExtension()
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(8)
              }
              Button("Supprimer la liste de blocage") {
                viewModel.removeBlockerList()
              }
              .padding()
              .frame(maxWidth: .infinity)
              .background(Color.red)
              .foregroundColor(.white)
              .cornerRadius(8)
            } else {
                Button("Installer la liste de blocage") {
                viewModel.reloadBlockerListExtension()
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
            .fill(Color.white)
        )
        .overlay(
          RoundedRectangle(cornerRadius: 16)
            .stroke(Color.gray.opacity(0.5), lineWidth: 1)
        )
        .padding(.top)

        VStack(alignment: .leading) {
          Group {
            Text("🛟 Améliorez le blocage")
              .font(.headline)
            Text(
              "Dans le but d'améliorer le blocage des appels et SMS indésirables, vous pouvez signaler les numéros qui ne sont pas bloqués par l'application. Cela aidera à enrichir la liste de blocage et à rendre l'application plus efficace. Pour cela envoyez un email à l'adresse suivante : saracroche@cbouvat.com"
            )
            .font(.footnote)
          }
          .padding(.bottom)

          Group {
            Text("❓Information sur les numéros bloqués")
              .font(.headline)

            Text(
              "L'application bloque les préfixes suivants, communiqués par l'ARCEP : 0162, 0163, 0270, 0271, 0377, 0378, 0424, 0425, 0568, 0569, 0948, 0949, ainsi que ceux allant de 09475 à 09479. Ces préfixes sont réservés au démarchage téléphonique."
            )
            .font(.footnote)
          }
          .padding(.bottom)

          Group {
            Text("🎁 Aidez au développement")
              .font(.headline)

            Text(
              "L'application Saracroche est open source et développée bénévolement. Si vous souhaitez soutenir le projet, vous pouvez faire un don via [GitHub Sponsors](https://github.com/sponsors/cbouvat). Votre aide est précieuse pour maintenir et améliorer l'application."
            )
            .font(.footnote)
          }
          .padding(.bottom)

          Group {
            Text("⭐️ Notez l'application sur l'App Store")
              .font(.headline)

            Text(
              "Si vous appréciez l'application Saracroche, n'hésitez pas à lui laisser une note sur l'App Store. Votre soutien nous aide à atteindre plus d'utilisateurs et à améliorer continuellement l'application."
            )
            .font(.footnote)
          }
          .padding(.bottom)
          
          Group {
            Text("🐛 Signaler un bug")
              .font(.headline)
            
            Text(
              "Si vous rencontrez un bug ou un problème avec l'application, merci de le signaler sur [GitHub](https://github.com/cbouvat/saracroche/issues) ou par email à l'adresse suivante : saracroche@cbouvat.com"
            )
            .font(.footnote)
          }
          .padding(.bottom)
          
          Group {
            Text("🔗 Liens utiles")
              .font(.headline)
            
            Text(
              "- Code source de l'application : [GitHub](https://github.com/cbouvat/saracroche)\n - Le site officiel de l'application : [cbouvat.com/saracroche](https://cbouvat.com/saracroche)\n - Suivez-moi sur Mastodon : [@cbouvat](https://mastodon.social/@cbouvat)\n\nBisous 😘"
            )
            .font(.footnote)
          }
          .padding(.bottom)
        }
        .padding()
        .background(
          RoundedRectangle(cornerRadius: 8)
            .fill(Color(.secondarySystemBackground))
        )
        .padding(.top)
      }
      .padding()
    }
  }
}

#Preview {
  ContentView()
}
