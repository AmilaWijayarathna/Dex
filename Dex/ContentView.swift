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
        animation: .default) private var allPokemons
    
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
        
        if allPokemons.isEmpty {
            
            ContentUnavailableView {
                Label("No Pokemons Found", image: .nopokemon)
            }description: {
                Text("Thre aren't any pokemons yet.\nFetch some pokemon to get started!")
            }actions: {
                Button("Fetch Pokemon", systemImage: "antenna.radiowaves.left.and.right") {
                    getPokemon(from: 0)
                }
                .buttonStyle(.borderedProminent)
            }
            
        }else{
            
            NavigationStack {
                List {
                    Section{
                        ForEach(pokedex) { pokemon in
                            NavigationLink(value : pokemon){
                                
                                if pokemon.sprite == nil{
                                    AsyncImage(url: pokemon.spriteURL){ image in
                                        image
                                            .resizable()
                                            .scaledToFit()
                                    }placeholder: {
                                        ProgressView()
                                    }
                                    .frame(width: 100, height: 100)
                                }else{
                                    pokemon.spriteImage
                                        .resizable()
                                        .scaledToFit()
                                }
                            
                                
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
                            }.swipeActions (edge:.leading){
                                Button(pokemon.favourite ? "Remove from favourites" : "Add to favourites", systemImage: "star"){
                                    pokemon.favourite.toggle()
                                }

                            }.tint(pokemon.favourite ? .yellow : .gray)
                            
                        }
                        
                    }footer:{
                        
                        if allPokemons.count < 151{
                            ContentUnavailableView {
                                Label("Missing Pokemon", image: .nopokemon)
                            }description: {
                                Text("The fetch was interrupted.\nFetch the rest of pokemon")
                            }actions: {
                                Button("Fetch Pokemon", systemImage: "antenna.radiowaves.left.and.right") {
                                    getPokemon(from: pokedex.count + 1)
                                }
                                .buttonStyle(.borderedProminent)
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
                    PokemonDetail()
                        .environmentObject(pokemon)
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
                }
                
            }
        }
    }
    
    private func getPokemon(from id: Int){
        
        Task{
            for i in id..<152 {
                
                do{
                    let fethedPokemon = try await fetcher.fetchPokemon(i)
                    
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
                    pokemon.spriteURL = fethedPokemon.spriteURL
                    pokemon.shinyURL = fethedPokemon.shinyURL
                    
                    if pokemon.id % 2 == 0{
                        pokemon.favourite = true
                    }
                    try viewContext.save()
                    
                }catch{
                    print(error)
                }
            }
            
            storeSprites()
        }
        
    }
    
    private func storeSprites(){
        
        Task {
            do{
                for pokemon in allPokemons{
                   
                    pokemon.sprite = try! await URLSession.shared.data(from: pokemon.spriteURL!).0
                    
                    pokemon.shiny = try! await URLSession.shared.data(from: pokemon.shinyURL!).0
                    try viewContext.save()
                    
                    print("saved\(pokemon.name)")
                }
            }catch {
                print(error)
            }
        }
        
       
    }

    
}
#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
