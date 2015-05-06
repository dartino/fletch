// Copyright (c) 2015, the Fletch project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE.md file.

library fletchc.lazy_field_initializer_codegen;

import 'package:compiler/src/dart2jslib.dart' show
    MessageKind,
    Registry;

import 'package:compiler/src/elements/elements.dart';
import 'package:compiler/src/resolution/resolution.dart';
import 'package:compiler/src/tree/tree.dart';

import 'fletch_context.dart';

import 'compiled_function.dart' show
    CompiledFunction;

import 'closure_environment.dart';
import 'codegen_visitor.dart';
import 'lazy_field_initializer_codegen.dart';

class DebugInfoLazyFieldInitializerCodegen
    extends LazyFieldInitializerCodegen {
  final FletchCompiler compiler;

  DebugInfoLazyFieldInitializerCodegen(CompiledFunction compiledFunction,
                                       FletchContext context,
                                       TreeElements elements,
                                       Registry registry,
                                       ClosureEnvironment closureEnvironment,
                                       FieldElement field,
                                       this.compiler)
      : super(compiledFunction, context, elements, registry,
              closureEnvironment, field);

  void recordDebugInfo(Node node) {
    compiledFunction.debugInfo.addLocation(compiler, builder.byteSize, node);
  }

  void pushVariableDeclaration(LocalValue value) {
    super.pushVariableDeclaration(value);
    compiledFunction.debugInfo.pushScope(builder.byteSize, value);
  }

  void popVariableDeclaration(Element element) {
    super.popVariableDeclaration(element);
    compiledFunction.debugInfo.popScope(builder.byteSize);
  }

  void registerDynamicInvocation(Selector selector) { }
  void registerDynamicGetter(Selector selector) { }
  void registerDynamicSetter(Selector selector) { }
  void registerStaticInvocation(FunctionElement function) { }
  void registerInstantiatedClass(ClassElement klass) { }

  void handleThisPropertySet(Send node) {
    recordDebugInfo(node);
    super.handleThisPropertySet(node);
  }

  void handleAllocationAndBodyCall() {
    // Clear out debug information after the initializer list. This avoids
    // seeing the code that sets up for the body call as part of the last
    // initializer evaluation.
    recordDebugInfo(null);
    super.handleAllocationAndBodyCall();
  }

  void invokeMethod(Node node, Selector selector) {
    recordDebugInfo(node);
    super.invokeMethod(node, selector);
  }

  void invokeGetter(Node node, Selector selector) {
    recordDebugInfo(node);
    super.invokeGetter(node, selector);
  }

  void invokeSetter(Node node, Selector selector) {
    recordDebugInfo(node);
    super.invokeSetter(node, selector);
  }

  void invokeFactory(Node node, int constId, int arity) {
    recordDebugInfo(node);
    super.invokeFactory(node, constId, arity);
  }

  void invokeStatic(Node node, int constId, int arity) {
    recordDebugInfo(node);
    super.invokeStatic(node, constId, arity);
  }

  void generateReturn(Node node) {
    recordDebugInfo(node);
    super.generateReturn(node);
  }

  void visitForValue(Node node) {
    recordDebugInfo(node);
    super.visitForValue(node);
  }

  void visitForEffect(Node node) {
    recordDebugInfo(node);
    super.visitForEffect(node);
  }
}
