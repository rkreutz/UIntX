extension Array {

    func removingFirst(where predicate: (Element) -> Bool) -> [Element] {

        var array = [Element]()
        var shouldContinueRemoving = true
        for value in self {

            shouldContinueRemoving = shouldContinueRemoving && predicate(value)
            if !shouldContinueRemoving { array.append(value) }
        }
        return array
    }

    func at(index: Index) -> Element? {

        guard
            index >= 0,
            index < count
            else { return nil }

        return self[index]
    }

    func removingOverflow() -> (result: Self, overflow: Bool) {

        let partsToBeRemoved = Swift.max(count - UIntXConfig.maximumNumberOfWords, 0)
        if partsToBeRemoved > 0 {

            return (Array(dropFirst(partsToBeRemoved)), true)
        } else {

            return (self, false)
        }
    }
}
