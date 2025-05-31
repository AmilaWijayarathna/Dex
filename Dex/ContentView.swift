//
//  ContentView.swift
//  Dex
//
//  Created by Amila Wijayarathna on 2025-04-23.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    
    @Query(sort:\Pokemon.id, animation: .default) private var pokedex: [Pokemon]
     
    private var dynamicPredicate : Predicate<Pokemon>{
        
        #Predicate<Pokemon> { pokemon in
            
            if filterByFavourite && !searchText.isEmpty{
                pokemon.favourite && pokemon.name.localizedStandardContains(searchText)
            }else if filterByFavourite{
                pokemon.favourite
            }else if !searchText.isEmpty{
                pokemon.name.localizedStandardContains(searchText)
            }else{
                true
            }
        }
        
    }
    
    
    let fetcher = FetchService()
    
    @State private var searchText: String = ""
    @State var filterByFavourite: Bool = false
    
    private var emptyStateView: some View {
        ContentUnavailableView {
            Label("No Pokemons Found", image: .nopokemon)
        } description: {
            Text("There aren't any pokemons yet.\nFetch some pokemon to get started!")
        } actions: {
            Button("Fetch Pokemon", systemImage: "antenna.radiowaves.left.and.right") {
                getPokemon(from: 0)
            }
            .buttonStyle(.borderedProminent)
        }
    }
    
    private func pokemonRow(for pokemon: Pokemon) -> some View {
        NavigationLink(value: pokemon) {
            HStack {
                Group {
                    if pokemon.sprite == nil {
                        AsyncImage(url: pokemon.spriteURL) { image in
                            image.resizable().scaledToFit()
                        } placeholder: {
                            ProgressView()
                        }
                    } else {
                        pokemon.spriteImage.resizable().scaledToFit()
                    }
                }
                .frame(width: 100, height: 100)

                VStack(alignment: .leading) {
                    HStack {
                        Text(pokemon.name.capitalized)
                            .font(.headline)
                            .fontWeight(.bold)

                        if pokemon.favourite {
                            Image(systemName: "star.fill")
                                .foregroundStyle(.yellow)
                        }
                    }

                    HStack {
                        ForEach(pokemon.types, id: \.self) { type in
                            Text(type.capitalized)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundStyle(.black)
                                .padding(.horizontal, 13)
                                .padding(.vertical, 5)
                                .background(Color(type.capitalized))
                                .clipShape(Capsule())
                        }
                    }
                }
            }
        }
        .swipeActions(edge: .leading) {
            Button(pokemon.favourite ? "Remove from favourites" : "Add to favourites", systemImage: "star") {
                pokemon.favourite.toggle()
                try? modelContext.save()
            }
        }
        .tint(pokemon.favourite ? .yellow : .gray)
    }

    var body: some View {
        
        if pokedex.isEmpty {
            
            emptyStateView
            
        }else{
            
            NavigationStack {
                List {
                    Section{
                        ForEach( (try? pokedex.filter(dynamicPredicate)) ?? pokedex) { pokemon in
                            pokemonRow(for: pokemon)
                            
                        }
                        
                    }footer:{
                        
                        if pokedex.count < 151{
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
                .animation(.default,value: searchText)
                .navigationDestination(for: Pokemon.self) { pokemon in
                    PokemonDetail(pokemon: pokemon)
                       
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button{
                            withAnimation {
                                filterByFavourite.toggle()
                            }
                           
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
                    modelContext.insert(fethedPokemon)
                    
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
                for pokemon in pokedex{
                   
                    pokemon.sprite = try! await URLSession.shared.data(from: pokemon.spriteURL).0
                    
                    pokemon.shiny = try! await URLSession.shared.data(from: pokemon.shinyURL).0
                    try modelContext.save()
                    
                    print("saved\(pokemon.name)")
                }
            }catch {
                print(error)
            }
        }
        
       
    }

    
}
#Preview {
    ContentView()
        .modelContainer(PersistenceController.preview)
}
