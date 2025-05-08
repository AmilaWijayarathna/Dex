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
    
    @FetchRequest<Pokemon>(
        sortDescriptors: [SortDescriptor(\.id)],
        animation: .default) private var pokedex
    
    private var dynamicPredicate : NSPredicate{
        
        var predicates : [NSPredicate] = []
        
        //search predicate
        if !searchText.isEmpty{
            predicates.append(NSPredicate(format: "name contains[c] %@", searchText))
        }
        
        //favourite predicate
        if filterByFavourite{
            predicates.append(NSPredicate(format:  "favourite == %d", true))
        }
        
        //combine predicates
        
        return NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        
    }
    
    
    let fetcher = FetchService()
    
    @State private var searchText: String = ""
    @State var filterByFavourite: Bool = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(pokedex) { pokemon in
                    NavigationLink(value : pokemon){
                        AsyncImage(url: pokemon.sprite){ image in
                            image
                                .resizable()
                                .scaledToFit()
                        }placeholder: {
                            ProgressView()
                        }
                        .frame(width: 100, height: 100)
                        
                        VStack(alignment: .leading) {
                            
                            HStack{
                                Text(pokemon.name!.capitalized)
                                    .font(.headline)
                                    .fontWeight(.bold)
                                
                                if pokemon.favourite{
                                    Image(systemName: "star.fill")
                                        .foregroundStyle(.yellow)
                                }
                            }
                            HStack {
                                ForEach(pokemon.types! ,id: \.self){ type in
                                    Text(type.capitalized)
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(.black)
                                        .padding(.horizontal, 13)
                                        .padding(.vertical, 5)
                                        .background(Color(type.capitalized))
                                        .clipShape(.capsule)
                                        
                                    
                                }
                            }
                            
                        }
                    }
                }
                
            }
            .navigationTitle("Pokedex")
            .searchable(text: $searchText , prompt : "Search Pokemon")
            .autocorrectionDisabled()
            .onChange(of: searchText) {
                pokedex.nsPredicate = dynamicPredicate
            }
            .onChange(of: filterByFavourite) {
                pokedex.nsPredicate = dynamicPredicate
            }
            .navigationDestination(for: Pokemon.self) { pokemon in
                Text(pokemon.name ?? "no name")
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button{
                        filterByFavourite.toggle()
                    }label:{
                        Label("Filter by favourite", systemImage: filterByFavourite ? "star.fill" : "star")
                    }
                    .tint(.yellow)
                }
                ToolbarItem {
                    Button("Add Item", systemImage: "plus") {
                        getPokemon()
                    }
                }
            }
            
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
                    
                    if pokemon.id % 2 == 0{
                        pokemon.favourite = true
                    }
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
