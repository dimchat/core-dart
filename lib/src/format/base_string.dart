/* license: https://mit-license.org
 * ==============================================================================
 * The MIT License (MIT)
 *
 * Copyright (c) 2026 Albert Moky
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 * ==============================================================================
 */
import 'package:mkm/type.dart';


class BaseString implements Stringer {
  BaseString(String string) : _str = string;

  String _str;

  // protected
  String getEncodedString() => _str;
  void setEncodedString(String string) => _str = string;

  @override
  String toString() => _str;

  @override
  bool operator ==(Object other) {
    if (other is Stringer) {
      if (identical(this, other)) {
        // same object
        return true;
      }
      // compare with inner string
      other = other.toString();
    }
    return other is String && other == toString();
  }

  @override
  int get hashCode => toString().hashCode;

  @override
  int get length => toString().length;

  @override
  bool get isEmpty => toString().isEmpty;

  @override
  bool get isNotEmpty => toString().isNotEmpty;

  @override
  int compareTo(String other) => toString().compareTo(other);

  //
  //  CharSequence
  //

  @override
  String operator [](int index) => toString()[index];

  @override
  int codeUnitAt(int index) => toString().codeUnitAt(index);

  @override
  bool endsWith(String other) => toString().endsWith(other);

  @override
  bool startsWith(Pattern pattern, [int index = 0]) =>
      toString().startsWith(pattern, index);

  @override
  int indexOf(Pattern pattern, [int start = 0]) =>
      toString().indexOf(pattern, start);

  @override
  int lastIndexOf(Pattern pattern, [int? start]) =>
      toString().lastIndexOf(pattern, start);

  @override
  String operator +(String other) => toString() + other;

  @override
  String substring(int start, [int? end]) => toString().substring(start, end);

  @override
  String trim() => toString().trim();

  @override
  String trimLeft() => toString().trimLeft();

  @override
  String trimRight() => toString().trimRight();

  @override
  String operator *(int times) => toString() * times;

  @override
  String padLeft(int width, [String padding = ' ']) =>
      toString().padLeft(width, padding);

  @override
  String padRight(int width, [String padding = ' ']) =>
      toString().padRight(width, padding);

  @override
  bool contains(Pattern other, [int startIndex = 0]) =>
      toString().contains(other, startIndex);

  @override
  String replaceFirst(Pattern from, String to, [int startIndex = 0]) =>
      toString().replaceFirst(from, to, startIndex);

  @override
  String replaceFirstMapped(Pattern from, String Function(Match match) replace,
      [int startIndex = 0]) =>
      toString().replaceFirstMapped(from, replace, startIndex);

  @override
  String replaceAll(Pattern from, String replace) =>
      toString().replaceAll(from, replace);

  @override
  String replaceAllMapped(Pattern from, String Function(Match match) replace) =>
      toString().replaceAllMapped(from, replace);

  @override
  String replaceRange(int start, int? end, String replacement) =>
      toString().replaceRange(start, end, replacement);

  @override
  List<String> split(Pattern pattern) => toString().split(pattern);

  @override
  String splitMapJoin(Pattern pattern,
      {String Function(Match)? onMatch, String Function(String)? onNonMatch}) =>
      toString().splitMapJoin(pattern, onMatch: onMatch, onNonMatch: onNonMatch);

  @override
  List<int> get codeUnits => toString().codeUnits;

  @override
  Runes get runes => toString().runes;

  @override
  String toLowerCase() => toString().toLowerCase();

  @override
  String toUpperCase() => toString().toUpperCase();

  //
  //  Pattern
  //

  @override
  Iterable<Match> allMatches(String string, [int start = 0]) =>
      toString().allMatches(string, start);

  @override
  Match? matchAsPrefix(String string, [int start = 0]) =>
      toString().matchAsPrefix(string, start);
}
