import CallKit
import Combine
import SwiftUI

class SaracrocheViewModel: ObservableObject {
  @Published var isBlockerEnabled: Bool = false
  @Published var blockerStatusMessage: String = "Vérification du statut..."
  @Published var blockerUpdateStatusMessage: String = ""
  @Published var blocklistVersion: String = "1"

  private var statusTimer: Timer? = nil
  private var updateTimer: Timer? = nil

  // List of phone number patterns to block
  let blockPhoneNumberPatterns: [String] = [
    "33162XXXXXX",
    "33163XXXXXX",
    "33270XXXXXX",
    "33271XXXXXX",
    "33377XXXXXX",
    "33378XXXXXX",
    "33424XXXXXX",
    "33425XXXXXX",
    "33568XXXXXX",
    "33569XXXXXX",
    "33948XXXXXX",
    "339475XXXXX",
    "339476XXXXX",
    "339477XXXXX",
    "339478XXXXX",
    "339479XXXXX",
  ]

  // List of phone number patterns to inform the user about (not blocked)
  let informPhoneNumberPatterns: [String] = [
    "33937XXXXXX",
    "33938XXXXXX",
    "33939XXXXXX",
  ]

  let sharedUserDefaults = UserDefaults(suiteName: "group.com.cbouvat.saracroche")

  init() {
    checkBlockerStatus()
    startStatusTimer()
    startUpdateTimer()
  }

  deinit {
    stopStatusTimer()
    stopUpdateTimer()
  }

  func checkBlockerStatus() {
    let blockerStatus = sharedUserDefaults?.string(forKey: "blockerStatus") ?? ""
    if blockerStatus == "update" { return }
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
          self.blockerStatusMessage = "Le bloqueur d'appels n'est pas activé"
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

  func updateBlockerStatusMessage() {
    let blockedNumbers = sharedUserDefaults?.integer(forKey: "blockedNumbers") ?? 0
    let totalBlockedNumbers = sharedUserDefaults?.integer(forKey: "totalBlockedNumbers") ?? 0
    let blockerStatus = sharedUserDefaults?.string(forKey: "blockerStatus") ?? ""

    if blockerStatus == "active" {
      self.blockerUpdateStatusMessage = "\(blockedNumbers) numéros bloqués"
    } else if blockerStatus == "update" {
      if blockedNumbers == 0 {
        self.blockerUpdateStatusMessage =
          "Installation de la liste de blocage en cours"
      } else {
        let percentage = totalBlockedNumbers > 0 ? (blockedNumbers * 100) / totalBlockedNumbers : 0
        self.blockerUpdateStatusMessage =
          "Installation de la liste de blocage en cours\n\n\(blockedNumbers) sur \(totalBlockedNumbers) numéros soit \(percentage)%"
      }
    } else if blockerStatus == "delete" {
      self.blockerUpdateStatusMessage = "Suppression de la liste de blocage en cours"
    } else {
      self.blockerUpdateStatusMessage = "Aucun numéro bloqué, installer la liste de blocage"
    }
  }

  func reloadBlockerListExtension() {
    let totalCount = countAllBlockedNumbers()

    sharedUserDefaults?.set("update", forKey: "blockerStatus")
    sharedUserDefaults?.set(totalCount, forKey: "totalBlockedNumbers")
    sharedUserDefaults?.set(0, forKey: "blockedNumbers")
    sharedUserDefaults?.set(self.blocklistVersion, forKey: "blocklistVersion")

    var patternsToProcess = blockPhoneNumberPatterns
    let manager = CXCallDirectoryManager.sharedInstance

    func processNextPattern() {
      sharedUserDefaults?.set("addPrefix", forKey: "action")
      if !patternsToProcess.isEmpty {
        let pattern = patternsToProcess.removeFirst()

        sharedUserDefaults?.set(pattern, forKey: "phonePattern")

        manager.reloadExtension(withIdentifier: "com.cbouvat.saracroche.blocker") { error in
          DispatchQueue.main.async {
            if error != nil {
              self.blockerStatusMessage = "Erreur lors du rechargement"
            }

            processNextPattern()
          }
        }
      } else {
        sharedUserDefaults?.set("active", forKey: "blockerStatus")
      }
    }

    sharedUserDefaults?.set("reset", forKey: "action")
    manager.reloadExtension(withIdentifier: "com.cbouvat.saracroche.blocker") { error in
      DispatchQueue.main.async {
        if error != nil {
          self.blockerStatusMessage = "Erreur lors du rechargement"
        }

        processNextPattern()
      }
    }
  }

  func removeBlockerList() {
    sharedUserDefaults?.set("delete", forKey: "blockerStatus")
    sharedUserDefaults?.set(0, forKey: "totalBlockedNumbers")
    sharedUserDefaults?.set(0, forKey: "blockedNumbers")
    sharedUserDefaults?.set("", forKey: "blocklistVersion")

    let manager = CXCallDirectoryManager.sharedInstance

    sharedUserDefaults?.set("reset", forKey: "action")
    manager.reloadExtension(withIdentifier: "com.cbouvat.saracroche.blocker") { error in
      DispatchQueue.main.async {
        if error != nil {
          self.blockerStatusMessage = "Erreur lors de la suppression"
        } else {
          self.sharedUserDefaults?.set("", forKey: "blockerStatus")
        }
      }
    }
  }

  func openSettings() {
    let manager = CXCallDirectoryManager.sharedInstance
    manager.openSettings(completionHandler: { error in
      if let error = error {
        print("Erreur lors de l'ouverture des réglages: \(error.localizedDescription)")
      }
    })
  }

  private func countAllBlockedNumbers() -> Int64 {
    var totalCount: Int64 = 0

    // Count all numbers using the patterns
    for pattern in blockPhoneNumberPatterns {
      let xCount = pattern.filter { $0 == "X" }.count
      totalCount += Int64(pow(10, Double(xCount)))
    }

    return totalCount
  }

  private func startStatusTimer() {
    statusTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [weak self] _ in
      self?.checkBlockerStatus()
    }
  }

  private func stopStatusTimer() {
    statusTimer?.invalidate()
    statusTimer = nil
  }

  private func startUpdateTimer() {
    updateTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { [weak self] _ in
      self?.updateBlockerStatusMessage()
    }
  }

  private func stopUpdateTimer() {
    updateTimer?.invalidate()
    updateTimer = nil
  }

  var isUpdateAvailable: Bool {
    let installedVersion = sharedUserDefaults?.string(forKey: "blocklistVersion") ?? ""
    return installedVersion != blocklistVersion
  }

  var blockerStatus: String {
    return sharedUserDefaults?.string(forKey: "blockerStatus") ?? ""
  }
}
