import SwiftUI

struct ReportNavigationView: View {
  var body: some View {
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
              "Dans le but d'améliorer le blocage des appels et SMS indésirables, il est possible de signaler les numéros qui ne sont pas bloqués par l'application. Cela contribuera à établir une liste de blocage et à rendre l'application plus efficace. Pour l'instant, le signalement se fait par e-mail."
            )
            .font(.body)
            .padding(.top, 4)
            .frame(maxWidth: .infinity, alignment: .leading)
          }

          Button {
            if let url = URL(
              string: "mailto:saracroche@cbouvat.com?subject=Signalement numéro"
            ) {
              UIApplication.shared.open(url)
            }
          } label: {
            HStack {
              Image(systemName: "envelope.fill")
              Text("Signaler un numéro")
            }
          }
          .buttonStyle(
            .fullWidth(background: Color("AppColor"), foreground: .black)
          )
          .padding(.top)
        }
        .padding()
      }
      .navigationTitle("Signaler")
    }
  }
}
