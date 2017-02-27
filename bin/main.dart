// Copyright (c) 2016, Ravi Teja Gudapati. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:gdbclient/gdbclient.dart' as client;

main(List<String> arguments)async {
  final lClient = new client.Client(aComm: new client.ClientComm(mPort: 1234));

  await lClient.open();

  await lClient.getGeneralRegisters();
}
