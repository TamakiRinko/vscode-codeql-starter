/**
 * @name Array index out of bounds
 * @description Accessing an array with an index that is greater than or equal to the
 *              length of the array causes an 'ArrayIndexOutOfBoundsException'.
 * @kind problem
 * @problem.severity error
 * @precision high
 * @id java/index-out-of-bounds
 * @tags reliability
 *       correctness
 *       exceptions
 *       external/cwe/cwe-193
 */

import java
import semmle.code.java.dataflow.SSA
import semmle.code.java.dataflow.RangeUtils
import semmle.code.java.dataflow.RangeAnalysis

/**
 * Holds if the index expression of `aa` is less than or equal to the array length plus `k`.
 * 如果aa的index值一定小于等于aa.length + k，返回true
 */
predicate boundedArrayAccess(ArrayAccess aa, int k) {
    // SSA:Static Single Assignment，静态单赋值，IR的一种形式，每个变量只被赋值一次，采用版本号机制
  exists(SsaVariable arr, Expr index, Bound b, int delta |
    //-----------------------第一个条件-------------------------------------------------------
    // 存在一个Bound b和一个int delta，使得delta是满足aa的下标表达式index <= b + delta的最小的那个

    // 找到每一次数组访问以及其对应的访问下标，注意：index是实际访问的下标，且*多维数组每一维都会考虑*
    aa.getIndexExpr() = index and
    // aa.getArray()返回当前访问的数组，是一个Expr
    // Expr getArray() { result.isNthChildOf(this, 0) }：result是这个数组访问Expr的第一个孩子，那么就是这个数组
    // 这里有问题！经过这个formula，多维数组的访问就只剩第一层的访问了！
    // TODO: 第一处改动
    // aa.getArray() = arr.getAUse() and
    aa.getArray+() = arr.getAUse() and
    // 判断 index <= b + delta 是否成立
    // 条件：存在aa一次使用的下标表达式index（使用时IR为arr），一个边界b，一个delta，使得index <= b + delta成立，且delta是最小的那个
    bounded(index, b, delta, true, _)
    //---------------------------------------------------------------------------------------
  |
    //-----------------------第二个条件-------------------------------------------------------
    // FieldAccess: An expression that accesses a field.
    exists(FieldAccess len |
      // 该域访问访问的是数组长度域，即访问的是arr.length这个域！
      len.getField() instanceof ArrayLengthField and
      // 访问的是该数组
      // TODO: 第三处改动
      // len.getQualifier() = arr.getAUse()
      len.getQualifier().(ArrayAccess).getArray*() = arr.getAUse() and
      // block就是长度域，找到使用了arr.length的那个边界
      b.getExpr() = len and
      // k即为delta，找到一个符合的k
      k = delta
    )
    or
    // 存在arr数组的创建语句arraycreation
    exists(ArrayCreationExpr arraycreation | arraycreation = getArrayDef(arr) |
      k = delta and
      // 数组的第一维长度 = b
      arraycreation.getDimension(getLevel(aa, arr)) = b.getExpr()
      or
      // 存在一个arrlen
      exists(int arrlen|
        // TODO: 第二处改动
        // 数组的第一维长度 = arrlen
        arraycreation.getDimension(getLevel(aa, arr)).(CompileTimeConstantExpr).getIntValue() = arrlen and
        // arraycreation.getADimension().(CompileTimeConstantExpr).getIntValue() = arrlen and
        // arraycreation.getDimension(ii).(CompileTimeConstantExpr).getIntValue() = arrlen and
        // arraycreation.getFirstDimensionSize() = arrlen and
        b instanceof ZeroBound and
        k = delta - arrlen
      )
    )
    //---------------------------------------------------------------------------------------
  )
}

int getLevel(ArrayAccess aa, SsaVariable arr){
  if aa.getArray() = arr.getAUse()  then result = 0
  else result = getLevel(aa.getArray(), arr) + 1
}

/**
 * Holds if the index expression is less than or equal to the array length plus `k`,
 * but not necessarily less than or equal to the array length plus `k-1`.
 * 找到最小的这样一个k，使得这次下标访问aa的index值一定小于等于arr.length + k。但不一定小于等于arr.length + k - 1
 * 这样的k如果大于等于0，说明有可能访问到了越界元素
 */
predicate bestArrayAccessBound(ArrayAccess aa, int k) {
  k = min(int k0 | boundedArrayAccess(aa, k0))
}

// ArrayAccess：一次数组访问，a[i]，是一个Expr的派生类
// ArrayAccess是包含多维数组的每一维访问的
from ArrayAccess aa, int k, string kstr
where
  // boundedArrayAccess(aa, k) and
  bestArrayAccessBound(aa, k) and
  k >= 0 and
  if k = 0 then kstr = "the array length" else kstr = "the array length + " + k
select aa,
  "This array access might be out of bounds, as the index might be equal to " + kstr
    + "."
