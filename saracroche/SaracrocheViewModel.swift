//
//  SaracrocheViewModel.swift
//  saracroche
//

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

  // List of phone number ranges to block
  let blockPhoneNumberRanges: [(start: Int64, end: Int64)] = [
    (33_162_000_000, 33_162_999_999),
    (33_163_000_000, 33_163_999_999),
    (33_270_000_000, 33_270_999_999),
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

  // List of phone number ranges to inform the user about (not blocked)
  let informPhoneNumberRanges: [(start: Int64, end: Int64)] = [
    (33_937_000_000, 33_937_999_999),
    (33_938_000_000, 33_938_999_999),
    (33_939_000_000, 33_939_999_999),
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

  func updateBlockerStatusMessage() {
    let blockedNumbers = sharedUserDefaults?.integer(forKey: "blockedNumbers") ?? 0
    let totalBlockedNumbers = sharedUserDefaults?.integer(forKey: "totalBlockedNumbers") ?? 0
    let blockerStatus = sharedUserDefaults?.string(forKey: "blockerStatus") ?? ""

    if blockerStatus == "active" {
      self.blockerUpdateStatusMessage = "🎉 \(blockedNumbers) numéros bloqués"
    } else if blockerStatus == "update" {
      if blockedNumbers == 0 {
        self.blockerUpdateStatusMessage =
          "Installation de la liste de blocage en cours... Garder l'application ouverte"
      } else {
        let percentage = totalBlockedNumbers > 0 ? (blockedNumbers * 100) / totalBlockedNumbers : 0
        self.blockerUpdateStatusMessage =
          "Installation de la liste de blocage en cours... \(blockedNumbers) numéros bloqués sur \(totalBlockedNumbers) numéros (\(percentage)%). Gardez l'application ouverte"
      }
    } else if blockerStatus == "delete" {
      self.blockerUpdateStatusMessage = "Suppression de la liste de blocage en cours..."
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

    var rangesToProcess = blockPhoneNumberRanges
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
        sharedUserDefaults?.set("active", forKey: "blockerStatus")
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

    // Compter tous les numéros en utilisant le tableau
    for range in blockPhoneNumberRanges {
      totalCount += (range.end - range.start + 1)
    }

    return totalCount
  }

  private func startStatusTimer() {
    statusTimer = Timer.scheduledTimer(withTimeInterval: 2.5, repeats: true) { [weak self] _ in
      self?.checkBlockerStatus()
    }
  }

  private func stopStatusTimer() {
    statusTimer?.invalidate()
    statusTimer = nil
  }

  private func startUpdateTimer() {
    updateTimer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) { [weak self] _ in
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
