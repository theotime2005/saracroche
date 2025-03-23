//
//  ContentView.swift
//  saracroche
//
//  Created by Camille Bouvat on 23/03/2025.
//

import SwiftUI
import CallKit

struct ContentView: View {
    @State private var isBlockerEnabled: Bool = false
    @State private var statusMessage: String = "Checking status..."
    
    var body: some View {
        VStack {
            Image(systemName: "phone")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Saracroche !")
            
            Spacer().frame(height: 20)
            
            Text("Call Blocker Status:")
                .font(.headline)
                .padding(.top)
            
            HStack {
                Image(systemName: isBlockerEnabled ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundColor(isBlockerEnabled ? .green : .red)
                Text(statusMessage)
            }
            .padding()
            
            Button("Check Status") {
                checkBlockerStatus()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .padding()
        .onAppear {
            checkBlockerStatus()
        }
    }
    
    private func checkBlockerStatus() {
        let manager = CXCallDirectoryManager.sharedInstance
        
        manager.getEnabledStatusForExtension(withIdentifier: "com.cbouvat.saracroche.blocker") { status, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.statusMessage = "Error: \(error.localizedDescription)"
                    self.isBlockerEnabled = false
                    return
                }
                
                switch status {
                case .enabled:
                    self.isBlockerEnabled = true
                    self.statusMessage = "Call blocker is active"
                case .disabled:
                    self.isBlockerEnabled = false
                    self.statusMessage = "Call blocker is disabled"
                case .unknown:
                    self.isBlockerEnabled = false
                    self.statusMessage = "Status unknown"
                @unknown default:
                    self.isBlockerEnabled = false
                    self.statusMessage = "Unexpected status"
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
