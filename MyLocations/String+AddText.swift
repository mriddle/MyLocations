extension String {
  mutating func addText(text: String?, withSeparator separator: String = "") -> String {
    if let text = text {
      if !isEmpty {
        self += separator
      }
      self += text
    }
    return self
  }
}