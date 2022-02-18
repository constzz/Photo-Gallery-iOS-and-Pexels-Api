import Foundation

extension String {
    var isNotEmpty: Bool {
        return !self.isEmpty
    }
    var isBlank: Bool {
        return self.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    var isNotBlank: Bool {
        return !self.isBlank
    }
}

extension Optional where Wrapped == String {
    var isNilOrEmpty: Bool {
        return (self ?? "").isEmpty
    }
    var isNotNilOrEmpty: Bool {
        return !self.isNilOrEmpty
    }
    var isNilOrBlank: Bool {
        return (self ?? "").isBlank
    }
    var isNotNilOrBlank: Bool {
        return !self.isNilOrBlank
    }
}
