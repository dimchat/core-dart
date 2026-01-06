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
import 'wrapper.dart';
import 'ted.dart';
import 'pnf.dart';


///
///  TED
///
abstract interface class TransportableDataWrapperFactory {

  TransportableDataWrapper createTransportableDataWrapper(Map map);

}

// Default factory
class _TransportableDataWrapperFactory implements TransportableDataWrapperFactory {
  @override
  TransportableDataWrapper createTransportableDataWrapper(Map map) {
    return BaseDataWrapper(map);
  }
}


///
///  PNF
///
abstract interface class PortableNetworkFileWrapperFactory {

  PortableNetworkFileWrapper createPortableNetworkFileWrapper(Map content);

}

// Default factory
class _PortableNetworkFileWrapperFactory implements PortableNetworkFileWrapperFactory {
  @override
  PortableNetworkFileWrapper createPortableNetworkFileWrapper(Map content) {
    return BaseFileWrapper(content);
  }
}


///
///  Singleton
///
class SharedNetworkFormatAccess {
  factory SharedNetworkFormatAccess() => _instance;
  static final SharedNetworkFormatAccess _instance = SharedNetworkFormatAccess._internal();
  SharedNetworkFormatAccess._internal();

  TransportableDataWrapperFactory tedWrapperFactory = _TransportableDataWrapperFactory();

  PortableNetworkFileWrapperFactory pnfWrapperFactory = _PortableNetworkFileWrapperFactory();

}
