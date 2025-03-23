//
//  ContentView.swift
//  saracroche
//
//  Created by Camille Bouvat on 23/03/2025.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "phone")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Saracroche !")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
