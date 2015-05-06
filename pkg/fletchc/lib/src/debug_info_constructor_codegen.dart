// Copyright (c) 2015, the Fletch project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE.md file.

library fletchc.debug_info_constructor_codegen;

import 'package:compiler/src/elements/elements.dart';
import 'package:compiler/src/resolution/resolution.dart';
import 'package:compiler/src/tree/tree.dart';
import 'package:compiler/src/universe/universe.dart';

import 'package:compiler/src/dart2jslib.dart' show
    Registry;

import 'bytecode_builder.dart';
import 'closure_environment.dart';
import 'codegen_visitor.dart';

import 'compiled_function.dart' show
    CompiledFunction;

import 'fletch_backend.dart';
import 'fletch_context.dart';
import 'constructor_codegen.dart';
import 'debug_info_lazy_field_initializer_codegen.dart';

class DebugInfoConstructorCodegen extends ConstructorCodegen {
  final FletchCompiler compiler;

  // Regenerate the bytecode in a fresh buffer separately from the compiled
  // function. If we did not create a separate buffer, the bytecode would
  // be appended to the compiled function builder and we would get a compiled
  // function with incorrect bytecode.
  BytecodeBuilder builder;

  DebugInfoConstructorCodegen(CompiledFunction compiledFunction,
                              FletchContext context,
                              TreeElements elements,
                              Registry registry,
                              ClosureEnvironment closureEnvironment,
                              ConstructorElement constructor,
                              CompiledClass compiledClass,
                              this.compiler)
      : super(compiledFunction, context, elements, registry,
              closureEnvironment, constructor, compiledClass) {
    builder = new BytecodeBuilder(super.builder.functionArity);
  }

  LazyFieldInitializerCodegen lazyFieldInitializerCodegenFor(
      CompiledFunction function,
      FieldElement field) {
    TreeElements elements = field.resolvedAst.elements;
    return new DebugInfoLazyFieldInitializerCodegen(
        function,
        context,
        elements,
        null,
        context.backend.createClosureEnvironment(field, elements),
        field,
        compiler);
  }

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
