//
//  ContentView.swift
//  Dex
//
//  Created by Amila Wijayarathna on 2025-04-23.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Pokemon.id, ascending: true)],
        animation: .default)
    private var pokedex: FetchedResults<Pokemon>
    
    let fetcher = FetchService()

    var body: some View {
        NavigationView {
            List {
                ForEach(pokedex) { pokemon in
                    NavigationLink {
                        Text(pokemon.name ?? "no name")
                    } label: {
                        Text(pokemon.name ?? "no name")
                    }
                }
                
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button("Add Item", systemImage: "plus") {
                        getPokemon()
                    }
                }
            }
            Text("Select an item")
        }
    }
    
    private func getPokemon(){
        
        Task{
            for id in 1..<152 {
                
                do{
                    let fethedPokemon = try await fetcher.fetchPokemon(id)
                    
                    let pokemon = Pokemon(context: viewContext)
                    pokemon.id = fethedPokemon.id
                    pokemon.name = fethedPokemon.name
                    pokemon.types = fethedPokemon.types
                    pokemon.hp = fethedPokemon.hp
                    pokemon.attack = fethedPokemon.attack
                    pokemon.defence = fethedPokemon.defense
                    pokemon.specialAttack = fethedPokemon.specialAttack
                    pokemon.specialDefence = fethedPokemon.specialDefence
                    pokemon.speed = fethedPokemon.speed
                    pokemon.sprite = fethedPokemon.sprite
                    pokemon.shiny = fethedPokemon.shiny
                    
                    try viewContext.save()
                    
                }catch{
                    print(error)
                }
            }
        }
        
    }

    
}
#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
