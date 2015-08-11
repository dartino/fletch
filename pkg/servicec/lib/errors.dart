// Copyright (c) 2015, the Fletch project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library servicec.errors;

abstract class ServiceCompilerError {
  final String path;

  ServiceCompilerError(this.path);
}

class UndefinedServiceError extends ServiceCompilerError {
  UndefinedServiceError(path)
      : super(path);
}