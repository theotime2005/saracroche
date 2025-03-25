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
  @State private var updateStatus: String = "finish"
  @State private var statusTimer: Timer? = nil
  @State private var updateTimer: Timer? = nil

  // List of phone number ranges to block
  @State private var phoneNumberRanges: [(start: Int64, end: Int64)] = [
    (33_162_000_000, 33_162_999_999),
    (33_163_000_000, 33_163_999_999),
    (33_271_000_000, 33_271_999_999),
    (33_377_000_000, 33_377_999_999),
    (33_378_000_000, 33_378_999_999),
    (33_424_000_000, 33_424_999_999),
    (33_425_000_000, 33_425_999_999),
    (33_568_000_000, 33_568_999_999),
    (33_569_000_000, 33_569_999_999),
    (33_948_000_000, 33_948_999_999),
    (33_947_500_000, 33_947_599_999),
    (33_947_600_000, 33_947_699_999),
    (33_947_700_000, 33_947_799_999),
    (33_947_800_000, 33_947_899_999),
    (33_947_900_000, 33_947_999_999),
  ]

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
    if updateStatus == "start" { return }
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
    let blockedNumbers = sharedUserDefaults?.integer(forKey: "blockedNumbers") ?? 0
    let totalBlockedNumbers = sharedUserDefaults?.integer(forKey: "totalBlockedNumbers") ?? 0
    let lastUpdate = sharedUserDefaults?.string(forKey: "lastUpdate") ?? ""

    if updateStatus == "finish" {
      if lastUpdate == "" {
        self.blockerUpdateStatusMessage = "Aucune mise à jour effectuée, recharger la liste"
      } else {
        self.blockerUpdateStatusMessage =
          "🎉 \(blockedNumbers) numéros bloqués, mise à jour faite le \(lastUpdate)"
      }
    } else if updateStatus == "start" {
      if blockedNumbers == 0 {
        self.blockerUpdateStatusMessage =
          "Mise à jour en cours... démarrage de la mise à jour, garder l'application ouverte"
      } else {
        let percentage = totalBlockedNumbers > 0 ? (blockedNumbers * 100) / totalBlockedNumbers : 0
        self.blockerUpdateStatusMessage =
          "Mise à jour en cours... \(blockedNumbers) numéros bloqués sur \(totalBlockedNumbers) numéros (\(percentage)%), gardez l'application ouverte"
      }
    } else {
      self.blockerUpdateStatusMessage = "Aucun numéro bloqué, rechargez la liste"
    }
  }

  private func reloadBlockerListExtension() {
    updateStatus = "start"
    let totalCount = countAllBlockedNumbers()
    
    sharedUserDefaults?.set(totalCount, forKey: "totalBlockedNumbers")
    sharedUserDefaults?.set(0, forKey: "blockedNumbers")
    
    var rangesToProcess = phoneNumberRanges
    let manager = CXCallDirectoryManager.sharedInstance
    
    func processNextRange() {
      sharedUserDefaults?.set("addPrefix", forKey: "action")
      if !rangesToProcess.isEmpty {
        let range = rangesToProcess.removeFirst()
        
        sharedUserDefaults?.set(range.start, forKey: "prefixesStart")
        sharedUserDefaults?.set(range.end, forKey: "prefixesEnd")
        
        manager.reloadExtension(withIdentifier: "com.cbouvat.saracroche.blocker") { error in
          DispatchQueue.main.async {
            if error != nil {
              self.blockerStatusMessage = "Erreur lors du rechargement"
            }
            
            processNextRange()
          }
        }
      } else {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        let formattedDate = formatter.string(from: date)
        sharedUserDefaults?.set(formattedDate, forKey: "lastUpdate")
        updateStatus = "finish"
      }
    }

    sharedUserDefaults?.set("reset", forKey: "action")
    manager.reloadExtension(withIdentifier: "com.cbouvat.saracroche.blocker") { error in
      DispatchQueue.main.async {
        if error != nil {
          self.blockerStatusMessage = "Erreur lors du rechargement"
        }
        
        processNextRange()
      }
    }
  }

  private func countAllBlockedNumbers() -> Int64 {
    var totalCount: Int64 = 0

    // Compter tous les numéros en utilisant le tableau
    for range in phoneNumberRanges {
      totalCount += (range.end - range.start + 1)
    }

    return totalCount
  }

  private func startStatusTimer() {
    statusTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
      self.checkBlockerStatus()
    }
  }

  private func stopStatusTimer() {
    statusTimer?.invalidate()
    statusTimer = nil
  }

  private func startUpdateTimer() {
    updateTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
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
