// Copyright (c) 2015, the Fletch project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE.md file.

#include "src/vm/heap_validator.h"

namespace fletch {

void HeapPointerValidator::VisitBlock(Object** start, Object** end) {
  for (; start != end; start++) {
    ValidatePointer(*start);
  }
}

void HeapPointerValidator::ValidatePointer(Object* object) {
  if (!object->IsHeapObject()) return;

  HeapObject* heap_object = HeapObject::cast(object);
  word address = heap_object->address();

  bool is_immutable_heap_obj = false;
  if (immutable_heap_ != NULL) {
    is_immutable_heap_obj =
        immutable_heap_->space()->Includes(address);
  }
  bool is_mutable_heap_obj = false;
  if (mutable_heap_ != NULL) {
    is_mutable_heap_obj = mutable_heap_->space()->Includes(address);
  }

  bool is_program_heap = program_heap_->space()->Includes(address);

  if (!is_immutable_heap_obj && !is_mutable_heap_obj && !is_program_heap) {
    fprintf(stderr,
            "Found pointer %p which lies in neither of "
            "immutable_heap/mutable_heap/program_heap.\n",
             heap_object);

    FATAL("Heap validation failed.");
  }

  Class* klass = heap_object->get_class();
  bool valid_class = program_heap_->space()->Includes(
      klass->address());
  if (!valid_class) {
    fprintf(stderr, "Object %p had an invalid klass pointer %p\n",
        heap_object, klass);
    FATAL("Heap validation failed.");
  }
}

void ProcessHeapValidatorVisitor::VisitProcess(Process* process) {
  Heap* process_heap = process->heap();
  Heap* process_immutable_heap = process->immutable_heap();

  // Validate pointers in immutable heap.
  {
    ImmutableHeapPointerValidator validator(
        process_immutable_heap, program_heap_);

    HeapObjectPointerVisitor pointer_visitor(&validator);
    process_immutable_heap->IterateObjects(&pointer_visitor);
  }

  // Validate pointers in roots, queues, weak pointers and mutable heap.
  {
    HeapPointerValidator validator(
        process_immutable_heap, process_heap, program_heap_);

    SafeObjectPointerVisitor pointer_visitor(process, &validator);
    process->IterateRoots(&validator);
    process_heap->IterateObjects(&pointer_visitor);
    process_heap->VisitWeakObjectPointers(&validator);
    process->store_buffer()->IterateObjects(&pointer_visitor);
    process->IteratePortQueuesPointers(&validator);
  }
}

}  // namespace fletch