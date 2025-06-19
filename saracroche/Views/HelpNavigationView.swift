import SwiftUI

struct HelpNavigationView: View {
  var requestReview: () -> Void
  var body: some View {
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
              "L'application utilise une extension de blocage d'appels et de SMS fournie par le système pour filtrer les numéros indésirables. Elle est conçue pour être simple et efficace, sans nécessiter de configuration complexe."
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
              "Pour signaler un numéro indésirable, utilisez le bouton 'Signaler' dans l'onglet 'Signaler'. Cela aidera à améliorer la liste de blocage et à rendre l'application plus efficace."
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
              "L'application Saracroche est open source et développée bénévolement. Vous pouvez soutenir le projet, ce qui est précieux pour maintenir et améliorer l'application."
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
              "Si l'application Saracroche vous est utile, une évaluation sur l'App Store serait appréciée. Ce soutien aide à toucher davantage de personnes et à améliorer continuellement l'application."
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
              "En cas de bug ou de problème avec l'application, merci de le signaler sur GitHub ou par e-mail."
            )
            .font(.body)
            .padding(.top, 4)
            .frame(maxWidth: .infinity, alignment: .leading)

            Button {
              if let url = URL(
                string: "https://github.com/cbouvat/saracroche/issues"
              ) {
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
              if let url = URL(
                string: "mailto:saracroche@cbouvat.com?subject=Signalement bug"
              ) {
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
  }
}
