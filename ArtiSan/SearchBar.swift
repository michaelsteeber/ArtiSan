//
//  SearchBar.swift
//  ArtiSan
//
//  Created by Michael Steeber on 9/22/24.
//

import SwiftUI

struct SearchBar: View {
    @Binding var searchText: String
    @Binding var searchResults: [Album]?
    
    var body: some View {
        HStack {
            TextField("Find an album", text: $searchText)
                .textFieldStyle(.roundedBorder)
                .onSubmit {
                    Task { await searchResults = makeRequest() }
                }
            Button("Search") {
                Task { await searchResults = makeRequest() }
            }
        }
        .padding(EdgeInsets(top: 5, leading: 10, bottom: 10, trailing: 10))
    }
    
    func makeRequest() async -> [Album]? {
        searchResults = nil
        var term = searchText.replacingOccurrences(of: " ", with: "+")
        term = term.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? ""
        print("TERM IS: \(term)")
        
        guard let url = URL(string: "https://itunes.apple.com/search?term=\(term)&entity=album&limit=25") else { return nil }
        
        guard let (data, response) = try? await URLSession.shared.data(from: url) else { return nil }
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else { return nil }
        
        /// A JSON Decoded is created.
        let decoder = JSONDecoder()
        /// The decoder attempts to decode the downloaded JSON data. If it fails, it returns nothing.
        //        do {
        //            let decodedInfo = try decoder.decode(iTunesResponse.self, from: data)
        //            print(decodedInfo)
        //            return(decodedInfo.results)
        //        } catch {
        //            print(error.localizedDescription)
        //            return nil
        //        }
        
        do {
            let decodedInfo = try decoder.decode(iTunesResponse.self, from: data)
            return decodedInfo.results
        } catch let DecodingError.dataCorrupted(context) {
            print("Data corrupted: \(context.debugDescription)")
            return nil
        } catch let DecodingError.keyNotFound(key, context) {
            print("Key '\(key.stringValue)' not found: \(context.debugDescription)")
            print("CodingPath:", context.codingPath)
            return nil
        } catch let DecodingError.valueNotFound(value, context) {
            print("Value '\(value)' not found: \(context.debugDescription)")
            print("CodingPath:", context.codingPath)
            return nil
        } catch let DecodingError.typeMismatch(type, context) {
            print("Type '\(type)' mismatch: \(context.debugDescription)")
            print("CodingPath:", context.codingPath)
            return nil
        } catch {
            print("Unexpected error: \(error.localizedDescription)")
            return nil
        }
        
    }
}

#Preview {
    SearchBar(searchText: .constant("Hello World"), searchResults: .constant([]))
}
