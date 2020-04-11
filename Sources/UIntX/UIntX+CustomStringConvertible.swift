extension UIntX: CustomStringConvertible {

    public var description: String {

        guard words.count != 1 else { return "\(words[0])" }

        switch Element.bitWidth / 4 {

        case ...0:
            return "0b" + parts
                .map { String($0, radix: 2, uppercase: false) }
                .joined()

        case 1...:
            let hexCount = Element.bitWidth / 4
            return "0x" + parts
                .map {

                    let valueString = String($0, radix: 16, uppercase: false)
                    let zeroPaddingString = (0 ..< hexCount - valueString.count).map { _ in "0" }.joined()
                    return zeroPaddingString + valueString
                }
                .joined()

        default:
            return ""
        }
    }
}
