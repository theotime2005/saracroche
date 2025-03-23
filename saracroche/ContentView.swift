//
//  ContentView.swift
//  saracroche
//

import SwiftUI
import CallKit

struct ContentView: View {
    @State private var isBlockerEnabled: Bool = false
    @State private var statusMessage: String = "Vérification du statut..."
    @State private var reloadStatusMessage: String = ""
    @State private var timer: Timer? = nil
    
    var body: some View {
        VStack {
            Image(systemName: "phone")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Saracroche")
            
            Spacer().frame(height: 20)
            
            Text("Statut du bloqueur d'appels")
                .font(.headline)
                .padding(.top)
            
            HStack {
                Image(systemName: isBlockerEnabled ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundColor(isBlockerEnabled ? .green : .red)
                Text(statusMessage)
            }
            .padding()
            
            if !isBlockerEnabled {
                Button("Activer dans les réglages") {
                    openSettings()
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            
            if isBlockerEnabled {
                Button("Recharger la liste des numéros de téléphone") {
                    reloadCallKitExtension()
                }
                .padding()
                .background(Color.orange)
                .foregroundColor(.white)
                .cornerRadius(8)

                Text(reloadStatusMessage)
                .padding(.top)
            }
            
            Text("Liste des préfixes bloqués par l'application :")
                .font(.headline)
                .padding(.top)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text("0162, 0163, 0270, 0271, 0377, 0378, 0424, 0425, 0568, 0569, 0948, 0949, 09475 à 09479")
                .font(.footnote)
                .padding(.top)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text("Les numéros de téléphone présents dans vos contacts ne seront pas bloqués.")
                .font(.footnote)
                .padding(.top)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .onAppear {
            checkBlockerStatus()
            reloadCallKitExtension()
            startTimer()
        }
        .onDisappear {
            stopTimer()
        }
    }
    
    private func checkBlockerStatus() {
        let manager = CXCallDirectoryManager.sharedInstance
        
        manager.getEnabledStatusForExtension(withIdentifier: "com.cbouvat.saracroche.blocker") { status, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.statusMessage = "Erreur: \(error.localizedDescription)"
                    self.isBlockerEnabled = false
                    return
                }
                
                switch status {
                case .enabled:
                    self.isBlockerEnabled = true
                    self.statusMessage = "Le bloqueur d'appels est actif"
                case .disabled:
                    self.isBlockerEnabled = false
                    self.statusMessage = "Le bloqueur d'appels est désactivé"
                case .unknown:
                    self.isBlockerEnabled = false
                    self.statusMessage = "Statut inconnu"
                @unknown default:
                    self.isBlockerEnabled = false
                    self.statusMessage = "Statut inattendu"
                }
            }
        }
    }
    
    private func reloadCallKitExtension() {
        let manager = CXCallDirectoryManager.sharedInstance
        manager.reloadExtension(withIdentifier: "com.cbouvat.saracroche.blocker") { error in
            DispatchQueue.main.async {
                if let error = error {
                    self.reloadStatusMessage = "Erreur de rechargement de la liste des numéros de téléphone"
                } else {
                    self.reloadStatusMessage = "La liste des numéros de téléphone a été rechargée avec succès"
                    self.checkBlockerStatus()
                }
            }
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.checkBlockerStatus()
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
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
