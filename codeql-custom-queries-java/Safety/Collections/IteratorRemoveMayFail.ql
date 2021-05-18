/**
 * @name Call to Iterator.remove may fail
 * @description Attempting to invoke 'Iterator.remove' on an iterator over a collection that does not
 *              support element removal causes a runtime exception.
 * @kind problem
 * @problem.severity warning
 * @precision medium
 * @id java/iterator-remove-failure
 * @tags reliability
 *       correctness
 *       logic
 */

import java

class SpecialCollectionCreation extends MethodAccess {
  SpecialCollectionCreation() {
    exists(Method m, RefType rt |
      m = this.(MethodAccess).getCallee() and rt = m.getDeclaringType()
    |
      rt.hasQualifiedName("java.util", "Arrays") and m.hasName("asList")
      or
      rt.hasQualifiedName("java.util", "Collections") and
      m.getName().regexpMatch("singleton.*|unmodifiable.*")
    )
  }
}

// 表达式e里面是否包含不变集合的构造origin
predicate containsSpecialCollection(Expr e, SpecialCollectionCreation origin) {
  e = origin        //e就是origin
  or
  exists(Variable v |
    containsSpecialCollection(v.getAnAssignedValue(), origin) and
    e = v.getAnAccess()     // e是变量访问，该变量被y赋值，y中有origin
  )
  or
  exists(Call c, int i |
    containsSpecialCollection(c.getArgument(i), origin) and
    e = c.getCallee().getParameter(i).getAnAccess()     // e是某函数的形参，对应实参中有origin
  )
  or
  exists(Call c, ReturnStmt r | e = c |
    r.getEnclosingCallable() = c.getCallee() and
    containsSpecialCollection(r.getResult(), origin)    // e是某函数的返回值，该返回值中有origin
  )
}

// 是否是不变集合的迭代器
predicate iterOfSpecialCollection(Expr e, SpecialCollectionCreation origin) {
  exists(MethodAccess ma | ma = e |
    containsSpecialCollection(ma.getQualifier(), origin) and
    ma.getCallee().hasName("iterator")
  )
  or
  exists(Variable v |
    iterOfSpecialCollection(v.getAnAssignedValue(), origin) and
    e = v.getAnAccess()
  )
  or
  exists(Call c, int i |
    iterOfSpecialCollection(c.getArgument(i), origin) and
    e = c.getCallee().getParameter(i).getAnAccess()
  )
  or
  exists(Call c, ReturnStmt r | e = c |
    r.getEnclosingCallable() = c.getCallee() and
    iterOfSpecialCollection(r.getResult(), origin)
  )
}

from MethodAccess remove, SpecialCollectionCreation scc
where
  remove.getCallee().hasName("remove") and
  iterOfSpecialCollection(remove.getQualifier(), scc)
select remove,
  "This call may fail when iterating over the collection created $@, since it does not support element removal.",
  scc, "here"
