import NaturalLanguage

public class FoodToCarbonConverter {
    private var embedding = NLEmbedding.wordEmbedding(for: .english)
    /// Mapping of lowercase words identifying a liquid type to a density in kg/l.
    private let liquidsDensities: Dictionary<String, Double> = ["oil":0.9, "water":1, "liquor":0.94]
    
    /// Returns a list of food types matching the given english keywords.
    /// The list is given in descending order according to how strong the match is.
    /// Can return nil if the device does not support english word embeddings or if no keywords are given.
    public func keywordsToTypes(_ keywords: [String]) -> [String]? {
        guard let embedding = embedding, keywords.count > 0 else { return nil }
        
        // lemmatize words and get a vector representation of the whole list
        let words = lemmatize(words: keywords)
        let vector = getMultiWordVector(words: words, embedding: embedding)
        
        // compute cosine similarity between vector and all the foods within the carbon-conversion database
        var results = Dictionary<String, Double>()
        for food in FoodToCarbonConverter.foodTypesInfo.keys {
            var foodVec = [Double]()
            if !embedding.contains(food) {
                // some entries in the carbon conversion database have spaces
                // as embeddings need one word only, compute an average vector of all words
                let foodWords = food.components(separatedBy: " ")
                foodVec = getMultiWordVector(words: foodWords, embedding: embedding)
            } else {
                foodVec = embedding.vector(for: food)!
            }
            let dist = 1 - (cosineSim(foodVec, vector) ?? -1)
            results[food] = dist
        }
        
        // sort by similarity and return the associated food types from the carbon conversion db
        return results.sorted{$0.value < $1.value}.map{$0.key}
    }
    
    /// Returns the carbon emissions in kg associated with the group of food products provided.
    /// If not enough information is available to determine a carbon emission, the resulting value for that product is considered 0.
    public func getCarbon(fromFoods foods: [Food]) -> Measurement<UnitMass> {
        let zeroKg = Measurement<UnitMass>(value: 0, unit: UnitMass.kilograms)
        var total = zeroKg
        for food in foods {
            total = total + (getCarbon(fromFood: food) ?? zeroKg)
        }
        
        return total
    }
    
    /// Returns the carbon emissions in kg associated with a food product. If not enough information is available, nil is returned instead.
    public func getCarbon(fromFood food: Food) -> Measurement<UnitMass>? {
        guard let type = food.types?.first else { return nil }
        guard let quantityInKg = toKg(food: food) else { return nil }
        guard let carbonDensity = FoodToCarbonConverter.foodTypesInfo[type]?.carbonDensity else { return nil }
        
        return Measurement<UnitMass>(value: carbonDensity * quantityInKg.value, unit: .kilograms)
    }
    
    /// Returns a food quantity converted to kg. If the food quantity provided is a liquid, the mass is calculated by estimating the density. Can return nil in case of failure.
    private func toKg(food: Food) -> Food.Quantity? {
        guard let quantity = food.quantity else { return nil }

        // food units can be both volume (e.g. ml) or mass (e.g. grams)
        var inKg: Double = 0
        if let massUnit = quantity.unit as? UnitMass {
            var measurement = Measurement(value: quantity.value, unit: massUnit)
            measurement.convert(to: .kilograms)
            inKg = measurement.value
        } else if let volumeUnit = quantity.unit as? UnitVolume {
            var measurement = Measurement(value: quantity.value, unit: volumeUnit)
            measurement.convert(to: .liters)
            // estimate density with word embeddings
            guard let type = food.types?.first,
                let density = getDensityLiquid(type: type) else { return nil }
            inKg = density * measurement.value
        } else {
            return nil
        }
        
        return Food.Quantity(value: inKg, unit: UnitMass.kilograms)
    }
    
    /// Returns the density of the liquid which most closely matches the liquid type given. Returns nil in case of failure.
    private func getDensityLiquid(type: String) -> Double? {
         guard let embedding = embedding else { return nil }
         
         var density = liquidsDensities["water"]
         var bestMatch = -1.0
         let vectorFood = getMultiWordVector(words: type.components(separatedBy: " "), embedding: embedding)
         for liquid in liquidsDensities {
             if let vectorLiquid = embedding.vector(for: liquid.key),
                 let sim = cosineSim(vectorFood, vectorLiquid), sim > bestMatch {
                 bestMatch = sim
                 density = liquid.value
             }
         }
         print("density of \(type): \(density ?? -1) kg/l")
         return density
     }
    
    /// Returns the lemmatized version of a list of english words .
    private func lemmatize(words: [String]) -> [String] {
        let tagger = NLTagger(tagSchemes: [.lemma])
        var finalWords = Set<String>()
        for word in words {
            tagger.string = word
            tagger.setLanguage(.english, range: word.startIndex..<word.endIndex)
            let (posTag, _) = tagger.tag(at: word.startIndex, unit: .word, scheme: .lemma)
            if let posTag = posTag {
                finalWords.insert(posTag.rawValue)
            } else {
                finalWords.insert(word)
            }
        }
        return Array(finalWords)
    }
    
    /// Returns the average vector representation of the given words using the word embedding provided. All words not within the embedding are filtered out.
    private func getMultiWordVector(words: [String], embedding: NLEmbedding) -> [Double] {
        let filtered = words.filter { embedding.contains($0) }
        let dim = Double(embedding.dimension)
        let zeroVector = Array(repeating: 0.0, count: embedding.dimension)
        var vector = zeroVector
        vector = filtered.reduce(vector) { sumVectors($0, embedding.vector(for: $1)!) ?? [] }
        return vector.map{ $0/dim }
    }

    /// Returns the dot product between two vectors or nil in case of failure.
    private func dotProduct(_ vector1: [Double], _ vector2: [Double]) -> Double? {
        guard !vector1.isEmpty && vector1.count == vector2.count else { return nil }
        var x: Double = 0
        for i in stride(from: 0, to: vector1.count, by: 1) {
            x += vector1[i] * vector2[i]
        }
        return x
    }

    /// Returns the magnitude of a vector or nil in case of failure.
    private func magnitude(_ vector: [Double]) -> Double? {
        guard !vector.isEmpty else { return nil }
        var x: Double = 0
        for elt in vector {
            x += elt * elt
        }
        return sqrt(x)
    }

    /// Returns the sum of two vectors or nil in case of failure.
    private func sumVectors(_ vector1: [Double], _ vector2: [Double]) -> [Double]? {
        guard !vector1.isEmpty && !vector2.isEmpty && vector1.count == vector2.count else { return nil }
        var sum = [Double]()
        for i in stride(from: 0, to: vector1.count, by: 1) {
            sum.append(vector1[i] + vector2[i])
        }
        return sum
    }

    /// Returns the cosine similarity between two vectors or nil in case of failure.
    private func cosineSim(_ vector1: [Double], _ vector2: [Double]) -> Double? {
        let magnitudeFirst = magnitude(vector1)
        let magnitudeSecond = magnitude(vector2)
        if let magnitudeFirst = magnitudeFirst, let magnitudeSecond = magnitudeSecond, let dotProduct = dotProduct(vector1, vector2) {
            return dotProduct / (magnitudeFirst * magnitudeSecond)
        }
        return nil
    }
}
