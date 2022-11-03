extension Array {

    func removingFirst(where predicate: (Element) -> Bool) -> [Element] {

        if let contiguousMatchingIndex = firstIndex(where: { !predicate($0) }) {
            return Array(dropFirst(contiguousMatchingIndex))
        } else {
            return []
        }
    }

    func align(to size: Int, paddingElement: Element) -> [Element] {
        let remainder = count % size
        guard remainder != 0 else { return self }
        return [Element](repeating: paddingElement, count: size - remainder) + self
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
