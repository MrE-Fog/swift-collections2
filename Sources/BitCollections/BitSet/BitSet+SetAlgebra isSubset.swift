//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift Collections open source project
//
// Copyright (c) 2021-2022 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

extension BitSet {
  /// Returns a Boolean value that indicates whether this set is a subset of
  /// the given set.
  ///
  /// Set *A* is a subset of another set *B* if every member of *A* is also a
  /// member of *B*.
  ///
  ///     let a: BitSet = [1, 2, 3, 4]
  ///     let b: BitSet = [1, 2, 4]
  ///     let c: BitSet = [0, 1]
  ///     a.isSubset(of: a) // true
  ///     b.isSubset(of: a) // true
  ///     c.isSubset(of: a) // false
  ///
  /// - Parameter other: Another bit set.
  ///
  /// - Returns: `true` if the set is a subset of `other`; otherwise, `false`.
  ///
  /// - Complexity: O(*max*), where *max* is the largest item in `self`.
  public func isSubset(of other: Self) -> Bool {
    self._read { first in
      other._read { second in
        let w1 = first._words
        let w2 = second._words
        if w1.count > w2.count {
          return false
        }
        for i in 0 ..< w1.count {
          if !w1[i].subtracting(w2[i]).isEmpty {
            return false
          }
        }
        return true
      }
    }
  }

  /// Returns a Boolean value that indicates whether this set is a subset of
  /// the values in a given sequence of integers.
  ///
  /// Set *A* is a subset of another set *B* if every member of *A* is also a
  /// member of *B*.
  ///
  ///     let a = [1, 2, 3, 4, -10]
  ///     let b: BitSet = [1, 2, 4]
  ///     let c: BitSet = [0, 1]
  ///     b.isSubset(of: a) // true
  ///     c.isSubset(of: a) // false
  ///
  /// - Parameter other: A sequence of arbitrary integers.
  ///
  /// - Returns: `true` if the set is a subset of `other`; otherwise, `false`.
  ///
  /// - Complexity: O(*max*) + *k*, where *max* is the largest item in `self`,
  ///    and *k* is the complexity of iterating over all elements in `other`.
  @inlinable
  public func isSubset<S: Sequence>(of other: S) -> Bool
  where S.Element == Int
  {
    if S.self == BitSet.self {
      return self.isSubset(of: other as! BitSet)
    }
    if S.self == BitSet.Counted.self {
      return self.isSubset(of: other as! BitSet.Counted)
    }
    if S.self == Range<Int>.self  {
      return self.isSubset(of: other as! Range<Int>)
    }
    if _storage.isEmpty { return true }
    var t = self
    for i in other {
      guard let i = UInt(exactly: i) else { continue }
      if t._remove(i), t.isEmpty { return true }
    }
    assert(!t.isEmpty)
    return false
  }

  public func isSubset(of other: BitSet.Counted) -> Bool {
    self.isSubset(of: other._bits)
  }

  /// Returns a Boolean value that indicates whether this set is a subset of
  /// the given range of integers.
  ///
  /// Set *A* is a subset of another set *B* if every member of *A* is also a
  /// member of *B*.
  ///
  ///     let b: BitSet = [0, 1, 2]
  ///     let c: BitSet = [2, 3, 4]
  ///     b.isSubset(of: -10 ..< 4) // true
  ///     c.isSubset(of: -10 ..< 4) // false
  ///
  /// - Parameter other: An arbitrary range of integers.
  ///
  /// - Returns: `true` if the set is a subset of `other`; otherwise, `false`.
  ///
  /// - Complexity: O(*max*), where *max* is the largest item in `self`.
  public func isSubset(of other: Range<Int>) -> Bool {
    _read { $0.isSubset(of: other._clampedToUInt()) }
  }
}
