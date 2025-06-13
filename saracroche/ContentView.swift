//
//  ContentView.swift
//  saracroche
//

import SwiftUI

struct ContentView: View {
  @StateObject private var viewModel = SaracrocheViewModel()

  var body: some View {
    VStack {
      VStack {
        Text("Saracroche")
          .font(.largeTitle)
          .fontWeight(.heavy)
          .foregroundColor(Color("AccentColor"))
          .frame(maxWidth: .infinity, alignment: .leading)

        Text("Statut du bloqueur d'appels")
          .font(.headline)
          .padding(.top)
          .frame(maxWidth: .infinity, alignment: .leading)

        HStack {
          Image(
            systemName: viewModel.isBlockerEnabled ? "checkmark.circle.fill" : "xmark.circle.fill"
          )
          .foregroundColor(viewModel.isBlockerEnabled ? .green : .red)
          Text(viewModel.blockerStatusMessage)
        }
        .padding(.top)
        .frame(maxWidth: .infinity, alignment: .leading)

        if !viewModel.isBlockerEnabled {
          Button("Activer dans les réglages") {
            viewModel.openSettings()
          }
          .padding()
          .background(Color.blue)
          .foregroundColor(.white)
          .cornerRadius(8)
        } else {
          Text("\(viewModel.blockerUpdateStatusMessage)")
            .font(.footnote)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical)

          if viewModel.blockerStatus == "update" {
            Button("Installation en cours...") {
              // Do nothing, installation is in progress
            }
            .padding()
            .background(Color.orange)
            .foregroundColor(.white)
            .cornerRadius(8)
          } else if viewModel.blockerStatus == "delete" {
            Button("Suppression en cours...") {
              // Do nothing, deletion is in progress
            }
            .padding()
            .background(Color.red)
            .foregroundColor(.white)
            .cornerRadius(8)
          } else if viewModel.blockerStatus == "active" {
            if viewModel.isUpdateAvailable {
              Button("Mettre à jour la liste de blocage") {
                viewModel.reloadBlockerListExtension()
              }
              .padding()
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
              .background(Color.green)
              .foregroundColor(.white)
              .cornerRadius(8)
            }
            Button("Supprimer la liste de blocage") {
              viewModel.removeBlockerList()
            }
            .padding()
            .background(Color.red)
            .foregroundColor(.white)
            .cornerRadius(8)
          } else {
            Button("Installer la liste de blocage") {
              viewModel.reloadBlockerListExtension()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
          }
        }
        
        VStack(alignment: .leading, spacing: 8) {
          Text("🛟 Améliorez le blocage")
            .font(.headline)

          Text(
            "Dans le but d'améliorer le blocage des appels indésirables, vous pouvez signaler les numéros qui ne sont pas bloqués par l'application. Cela nous aidera à enrichir la liste de blocage et à rendre l'application plus efficace. Pour cela envoyez un email à l'adresse suivante : saracroche@cbouvat.com"
          )
          .font(.footnote)
          .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(
          RoundedRectangle(cornerRadius: 8)
            .fill(Color(.systemBackground))
        )
        .overlay(
          RoundedRectangle(cornerRadius: 8)
            .stroke(Color.gray, lineWidth: 1)
        )
        .padding(.top)
        
        VStack(alignment: .leading, spacing: 8) {
          Text("❓Information sur les numéros bloqués")
            .font(.headline)

          Text(
            "L'application bloque les préfixes suivants, communiqués par l'ARCEP : 0162, 0163, 0270, 0271, 0377, 0378, 0424, 0425, 0568, 0569, 0948, 0949, ainsi que ceux allant de 09475 à 09479. Ces préfixes sont réservés au démarchage téléphonique."
          )
          .font(.footnote)
          .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(
          RoundedRectangle(cornerRadius: 8)
            .fill(Color(.systemBackground))
        )
        .overlay(
          RoundedRectangle(cornerRadius: 8)
            .stroke(Color.gray, lineWidth: 1)
        )
        .padding(.top)
        
        VStack(alignment: .leading, spacing: 8) {
          Text("🎁 Aidez au développement")
            .font(.headline)

          Text(
            "L'application Saracroche est open source et développée bénévolement. Si vous souhaitez soutenir le projet, vous pouvez faire un don via GitHub Sponsors. Votre aide est précieuse pour maintenir et améliorer l'application."
          )
          .font(.footnote)
          .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(
          RoundedRectangle(cornerRadius: 8)
            .fill(Color(.systemBackground))
        )
        .overlay(
          RoundedRectangle(cornerRadius: 8)
            .stroke(Color.gray, lineWidth: 1)
        )
        .padding(.top)
        
        VStack(alignment: .leading, spacing: 8) {
          Text("⭐️ Notez l'application sur l'App Store")
            .font(.headline)

          Text(
            "Si vous appréciez l'application Saracroche, n'hésitez pas à lui laisser une note sur l'App Store. Votre soutien nous aide à atteindre plus d'utilisateurs et à améliorer continuellement l'application."
          )
          .font(.footnote)
          .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(
          RoundedRectangle(cornerRadius: 8)
            .fill(Color(.systemBackground))
        )
        .overlay(
          RoundedRectangle(cornerRadius: 8)
            .stroke(Color.gray, lineWidth: 1)
        )
        .padding(.top)
        
      }
      .padding()
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    .edgesIgnoringSafeArea(.bottom)
  }
}

#Preview {
  ContentView()
}
