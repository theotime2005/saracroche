//
//  ContentView.swift
//  saracroche
//

import CallKit
import SwiftUI

struct ContentView: View {
  @State private var isBlockerEnabled: Bool = false
  @State private var blockerStatusMessage: String = "Vérification du statut..."
  @State private var blockerUpdateStatusMessage: String = ""
  @State private var statusTimer: Timer? = nil
  @State private var updateTimer: Timer? = nil

  let sharedUserDefaults = UserDefaults(suiteName: "group.com.cbouvat.saracroche")

  var body: some View {
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
        Image(systemName: isBlockerEnabled ? "checkmark.circle.fill" : "xmark.circle.fill")
          .foregroundColor(isBlockerEnabled ? .green : .red)
        Text(blockerStatusMessage)
      }
      .padding(.top)
      .frame(maxWidth: .infinity, alignment: .leading)

      if !isBlockerEnabled {
        Button("Activer dans les réglages") {
          openSettings()
        }
        .padding()
        .background(Color.blue)
        .foregroundColor(.white)
        .cornerRadius(8)
      } else {
        Text("\(blockerUpdateStatusMessage)")
          .font(.footnote)
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding(.vertical)

        Button("Recharger la liste des numéros de téléphone") {
          reloadBlockerListExtension()
        }
        .padding()
        .background(Color.orange)
        .foregroundColor(.white)
        .cornerRadius(8)
      }

      Text("Liste des préfixes bloqués")
        .font(.headline)
        .padding(.top)
        .frame(maxWidth: .infinity, alignment: .leading)

      Text(
        "0162, 0163, 0270, 0271, 0377, 0378, 0424, 0425, 0568, 0569, 0948, 0949, 09475 à 09479. Cette liste est basée sur les numéros du plan de numérotation français fournis par l'ARCEP."
      )
      .font(.footnote)
      .frame(maxWidth: .infinity, alignment: .leading)

      Text("⚠ Les numéros de téléphone présents dans vos contacts ne seront pas bloqués.")
        .font(.footnote)
        .padding(.top)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    .padding()
    .onAppear {
      checkBlockerStatus()
      startStatusTimer()
      startUpdateTimer()
    }
    .onDisappear {
      stopStatusTimer()
      stopUpdateTimer()
    }
  }

  private func checkBlockerStatus() {
    let manager = CXCallDirectoryManager.sharedInstance

    manager.getEnabledStatusForExtension(withIdentifier: "com.cbouvat.saracroche.blocker") {
      status, error in
      DispatchQueue.main.async {
        if error != nil {
          self.isBlockerEnabled = false
          self.blockerStatusMessage = "Erreur"
          return
        }

        switch status {
        case .enabled:
          self.isBlockerEnabled = true
          self.blockerStatusMessage = "Le bloqueur d'appels est actif"
        case .disabled:
          self.isBlockerEnabled = false
          self.blockerStatusMessage = "Le bloqueur d'appels est désactivé"
        case .unknown:
          self.isBlockerEnabled = false
          self.blockerStatusMessage = "Statut inconnu"
        @unknown default:
          self.isBlockerEnabled = false
          self.blockerStatusMessage = "Statut inattendu"
        }
      }
    }
  }

  private func updateBlockerStatusMessage() {
    let updateStatus = sharedUserDefaults?.string(forKey: "updateStatus") ?? ""
    let blockedNumbers = sharedUserDefaults?.integer(forKey: "blockedNumbers") ?? 0
    let totalBlockedNumbers = sharedUserDefaults?.integer(forKey: "totalBlockedNumbers") ?? 0

    if updateStatus == "finish" {
      if let lastUpdate = sharedUserDefaults?.object(forKey: "lastUpdate") as? Date {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        let formattedDate = formatter.string(from: lastUpdate)
        self.blockerUpdateStatusMessage =
          "🎉 \(blockedNumbers) numéros bloqués, mise à jour faite le \(formattedDate)"
      } else {
        self.blockerUpdateStatusMessage = "\(blockedNumbers) numéros bloqués"
      }
    } else if updateStatus == "start" {
      if blockedNumbers == 0 {
        self.blockerUpdateStatusMessage =
          "Mise à jour en cours... démarrage de la mise à jour, garder l'application ouverte"
      } else {
        self.blockerUpdateStatusMessage =
          "Mise à jour en cours... \(blockedNumbers) numéros bloqués sur \(totalBlockedNumbers) numéros, gardez l'application ouverte"
      }
    } else {
      self.blockerUpdateStatusMessage = "Aucun numéro bloqué, rechargez la liste"
    }
  }

  private func reloadBlockerListExtension() {
    sharedUserDefaults?.set("start", forKey: "updateStatus")
    sharedUserDefaults?.set(0, forKey: "blockedNumbers")

    let manager = CXCallDirectoryManager.sharedInstance
    manager.reloadExtension(withIdentifier: "com.cbouvat.saracroche.blocker") { error in
      DispatchQueue.main.async {
        if error != nil {
          self.blockerStatusMessage = "Erreur lors du rechargement"
        }
      }
    }
  }

  private func startStatusTimer() {
    statusTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { _ in
      self.checkBlockerStatus()
    }
  }

  private func stopStatusTimer() {
    statusTimer?.invalidate()
    statusTimer = nil
  }

  private func startUpdateTimer() {
    updateTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
      self.updateBlockerStatusMessage()
    }
  }

  private func stopUpdateTimer() {
    updateTimer?.invalidate()
    updateTimer = nil
  }

  private func openSettings() {
    let manager = CXCallDirectoryManager.sharedInstance
    manager.openSettings(completionHandler: { error in
      if let error = error {
        print("Erreur lors de l'ouverture des réglages: \(error.localizedDescription)")
      }
    })
  }
}

#Preview {
  ContentView()
}
