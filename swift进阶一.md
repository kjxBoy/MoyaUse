[TOC]

# Swift进阶_第一部分

## 介绍

### 术语

>  你用，或是不用，术语就在那里，不多不少。你懂，或是不懂，定义就在那里，不偏不倚。

    1.'值(value)'是不变的，永久的，它从不会改变，'结构体'和 '枚举'是值类型。当你把一个结构体变量赋值给另一个，那么这两个变量将会包含同样的值。这里可能为使用协议的时候
    你可以将它理解为内容被复制了一遍，但是更精确地描述的话,是被赋值的变量与另外的那个变量包含了同样的值
    
    2.'类(class)'是引用类型 (reference type)
    
    3.'===' 运算符实际做的是询问“这两个变量是不是持有同样的引用”,在程序语言的论文里，'==' 有时候被称为结构相等，而 '===' 则被称为指针相等或者引用相等。
    
    4.在 Swift中变量不会存在未定义状态,变量包括'var'和'let'声明的，'let'声明的为'常量变量'，'var'声明的为'变量'
    
    5.Swift 的数组只有当其中的元素满足值语义时，数组本身才具有值语义。
    
    6.有些类是完全不可变的，也就是说，从被创建以后，它们就不提供任何方法来改变它们的内部状态。这意味着即使它们是类，它们依然具有值语义 (因为它们就算被到处使用也从不会改变)。
    但是要注意的是，只有那些标记为'final' 的类能够保证不被子类化，也不会被添加可变状态。
    
    7.在 Swift 中，函数也是值。如果一个函数接受别的函数作为参数 (比如 map 函数接受一个转换函数，并将其应用到数组中的所有元素上)，或者一个函数的返回值是函数，
    那么这样的函数就叫做'高阶函数 (higher-order function)'。
    
    8.如果一个函数被定义在外层作用域中，但是被传递出这个作用域 (比如把这个函数被作为其他函数的返回值返回时)，它将能够“捕获”局部变量。
    这些局部变量将存在于函数中，不会随着局部作用域的结束而消亡，函数也将持有它们的状态。这种行为的变量被称为“闭合变量”，我们把这样的函数叫做'闭包 (closure)'。
    
    9.使用'func'关键字定义的函数，如果它包含了外部的变量，那么它也是一个闭包。
    
    10.当两个闭包持有同样的局部变量时，它们是共享这个变量以及它的状态的
    
### swift风格指南

    -> 优先选择'结构体'，只在确实需要使用到类特有的特性或者是引用语义时才使用类。
    
    2. 除非你的设计就是希望某个类被继承使用，否则都应该将它们标记为'final'
    
    3. 尽可能地对现有的类型和协议进行扩展，而不是写一些全局函数。这有助于提高可读性，让别人更容易发现你的代码。

    
## 内建集合类型
 
### 数组
 
#### 数组和可选值
 
> 想要迭代数组？ for x in array
> 
> 想要迭代除了第一个元素以外的数组其余部分？ for x in array.dropFirst()
> 
> 想要迭代除了最后 5 个元素以外的数组？ for x in array.dropLast(5)
> 
> 想要列举数组中的元素和对应的下标？ for (num, element) in collection.enumerated()
> 
> 想要寻找一个指定元素的位置？ if let idx = array.index { someMatchingLogic($0) }
```
For array items that don't conform to Equatable you'll need to use index(where:):

let index = cells.index(where: { (item) -> Bool in
  item.foo == 42 // test if this is the item you're looking for
})
```
> 
> 想要对数组中的所有元素进行变形？ array.map { someTransformation($0) }
> 
> 想要筛选出符合某个标准的元素？ array.filter { someCriteria($0) > }
 
#### 数组变形

##### 使用函数将行为参数化

reduce(into:_:)
```
 /// counts 与 into 后面的类型相同，letter是对应的元素类型
        let letters = "abracadabra"
        let letterCount = letters.reduce(into: [:]) { counts, letter in
                 counts[letter, default: 0] += 1
             }
        print(letterCount)
        // letterCount == ["a": 5, "b": 2, "r": 2, "c": 1, "d": 1]
```

##### 可变和带有状态的闭包

```
extension Array {
    func accumulate<Result>(_ initialResult: Result, 
        _ nextPartialResult: (Result, Element) -> Result) -> [Result] 
    {
        var running = initialResult
        return map { next in
            running = nextPartialResult(running, next)
            return running
        }
    }
}

[1,2,3,4].accumulate(0, +) // [1, 3, 6, 10]

```

##### Reduce

reduce 方法对应这种模式，它把一个初始值 (在这里是 0) 以及一个将中间值 (total) 与序列中的元素 (num) 进行合并的函数进行了抽象。使用 reduce的例子写为这样：


```
let fibs = [0, 1, 1, 2, 3, 5]
let sum = fibs.reduce(0) { total, num in total + num } 
// 运算符也是函数，所以我们也可以把上面的例子写成这样：
fibs.reduce(0, +) 
//reduce 的输出值的类型可以和输入的类型不同。举个例子，我们可以将一个整数的列表转换为一个字符串，这个字符串中每个数字后面跟一个空格：
fibs.reduce("") { str, num in str + "\(num), " } // 0, 1, 1, 2, 3, 5, 


// reduce(into:_:) 中的第一个参数，是inout类型，可以被外界修改 ，因此result就是最后的返回结果 
        let letterShow = letters.reduce(into: "") { (result, character) in
            result.append("+\(character)")
            
        }
        print(letterShow)
        // +a+b+r+a+c+a+d+a+b+r+a

```



### 字典 

#### 有用的字典方法

> Dictionary 有一个 merge(_:uniquingKeysWith:)，它接受两个参数，第一个是要进行合并的键值对，第二个是定义如何合并相同键的两个值的函数。我们可以使用这个方法将一个字典合并至另一个字典中去，如下例所示：
> 

```
var settings = defaultSettings
let overriddenSettings: [String:Setting] = ["Name": .text("Jane's iPhone")]
settings.merge(overriddenSettings, uniquingKeysWith: { $1 })
settings
// ["Name": Setting.text("Jane\'s iPhone"), "Airplane Mode": Setting.bool(false)]
```

> 因为 Dictionary 已经是一个 Sequence 类型，它已经有一个 map 函数来产生数组。不过我们有时候想要的是结果保持字典的结构，只对其中的值进行映射。mapValues 方法就是做这件事的：

```
enum Setting {
    case text(String)
    case int(Int)
    case bool(Bool)
}

let defaultSettings: [String:Setting] = [
            "Airplane Mode": .bool(false),
            "Name": .text("My iPhone"),
            ]
        
        print(defaultSettings)
        
        // 返回一个新的字典，包含原来字典的Key值，和通过闭包变换后的value
        /// Returns a new dictionary containing the keys of this dictionary with the
        /// values transformed by the given closure.
        
        let settingsAsStrings = defaultSettings.mapValues { setting -> String in
            switch setting {
            case .text(let text): return text
            case .int(let number): return String(number)
            case .bool(let value): return String(value)
            }
        }
        
        print(settingsAsStrings) // ["Name": "My iPhone", "Airplane Mode": "false"]

```

### 集合Set 

> 标准库中第三种主要的集合类型是集合 Set (虽然听起来有些别扭)。集合是一组无序的元素， 每个元素只会出现一次。

> 你可以将集合想像为一个只存储了键而没有存储值的字典。和 Dictionary 一样，Set 也是通过**哈希表**实现的，并拥有类似的性能特性和要求。==测试集合中是否包含某个元素是一个常数时间的操作，和字典中的键一样，集合中的元素也必须满足 Hashable==。

> 如果你需要高效地测试某个元素是否存在于序列中并且元素的顺序不重要时，使用集合是更好的选择 (同样的操作在数组中的复杂度是 O(n)，集合是O(1))。另外，当你需要保证序列中不出现重复元素 时，也可以使用集合。
> Set 遵守 ExpressibleByArrayLiteral 协议，也就是说，我们可以用数组字面量的方式初始化一 个集合:


#### 集合代数（交集、并集、补集）
集合可以实现在高中时期学习的关于集合的运算，**交集、并集、补集**

补集

```
let iPods: Set = ["iPod touch", "iPod nano", "iPod mini", 
    "iPod shuffle", "iPod Classic"]
let discontinuedIPods: Set = ["iPod mini", "iPod Classic", 
    "iPod nano", "iPod shuffle"]
let currentIPods = iPods.subtracting(discontinuedIPods) // ["iPod touch"]
```

交集
```
let touchscreen: Set = ["iPhone", "iPad", "iPod touch", "iPod nano"]
let iPodsWithTouch = iPods.intersection(touchscreen)
// ["iPod touch", "iPod nano"]
```
并集

```
var discontinued: Set = ["iBook", "Powerbook", "Power Mac"]
discontinued.formUnion(discontinuedIPods)
discontinued
/*
["iBook", "Powerbook", "Power Mac", "iPod Classic", "iPod mini",
 "iPod shuffle", "iPod nano"]
*/
```

### Range
> 范围代表的是两个值的区间，它由上下边界进行定义

> 不能对 Range 或者 ClosedRange 进行迭代，但是我们可以检查某个元素是否存在于范围 中:

> Range 和 ClosedRange 既非序列，也不是集合类型。有一部分范围确实是序列

> 是因为 0..<10 的类型其实是一个 CountableRange<Int>。 CountableRange 和 Range 很相似，只不过它还需要一个附加约束:它的元素类型需要遵守 Strideable 协议 (以整数为步⻓)。Swift 将这类功能更强的范围叫做可数范围，这是因为只有这 类范围可以被迭代。可数范围的边界可以是整数或者指针类型，但不能是浮点数类型，这是由 于 Stride 类型中有一个整数的约束。如果你想要对连续的浮点数值进行迭代的话，你可以通过 使用 stride(from:to:by) 和 stride(from:through:by) 方法来创建序列用以迭代。


—— | 半开范围 | 闭合范围
---|---|---
元素满足 Comparable | Range | ClosedRange
元素满足 Strideable(以整数为步长) | CountableRange | CountableClosedRange

#### 部分范围

> 部分范围 (partial range) 指的是将 ... 或 ..< 作为前置或者后置运算符来使用时所构造的范围。


```
let fromA: PartialRangeFrom<Character> = Character("a")...
let throughZ: PartialRangeThrough<Character> = ...Character("z") 
let upto10: PartialRangeUpTo<Int> = ..<10
let fromFive: CountablePartialRangeFrom<Int> = 5...
```
> 其中能够计数的只有 CountablePartialRangeFrom 这一种类型，四种部分范围类型中，只有它 能被进行迭代。迭代操作会从 lowerBound 开始，不断重复地调用 advanced(by: 1)。如果你在 一个 for 循环中使用这种范围，你必须牢记要为循环添加一个 break 的退出条件，否则循环将 无限进行下去 (或者当计数溢出的时候发生崩溃)。PartialRangeFrom 不能被迭代，这是因为它 的 Bound 不满足 Strideable。而 PartialRangeThrough 和 PartialRangeUpTo 则是因为没有 下界而无法开始迭代。

#### 范围表达式
同时省略掉上、下两个边界，这样你将会得到整个集合类型的切片

```
let arr = [1,2,3,4]
arr[...] // [1, 2, 3, 4] 
type(of: arr) // Array<Int>
```



## 集合类型协议
### 序列（sequence）
> 一个序列 (sequence) 代表的是一系列具有相同类型 的值，每当你遇到一个能够针对元素序列进行的通用 的操作，你都应该考虑将它实现在 Sequence 层的可能性。

> 在计算机科学的理论中，链表对一些常用操作会比数组高效得多。但是实际上，在当 代的计算机架构上，CPU 缓存速度非常之快，相对来说主内存的速度要慢一些，这让 链表的性能很难与数组相媲美。因为数组中的元素使用的是连续的内存，处理器能够 以更高效的方式对它们进行访问。

```
// 提供一个返回迭代器 (iterator) 的 makeIterator() 方法
protocol Sequence {
    associatedtype Iterator: IteratorProtocol
    func makeIterator() -> Iterator
    // ...
}

// - parameter next()这个方法需 要在每次被调用时返回序列中的下一个值。当序列被耗尽时，next() 应该返回 nil
// - parameter 关联类型 Element 指定了迭代器产生的值的类型,比如 String 的迭代器的元素类型是 Character。
protocol IteratorProtocol { 
    associatedtype Element mutating 
    func next() -> Element?
}

public protocol Sequence { 
    associatedtype Element 
    associatedtype Iterator: IteratorProtocol where Iterator.Element == Element // ...
}

eg：
/// for 循环其实是下面这段代码 的一种简写形式
// 1.创建一个简单的迭代器
var iterator = someSequence.makeIterator() 
// 2.遍历迭代器，直到返回nil结束
while let element = iterator.next() {
    doSomething(with: element) 
}

// 迭代器是单向结构，它只能按照增加的方向前进，而不能倒退或者重置。
//自己可以创建一个无限的，永不枯竭的序列(每次返回同样的值，不返回nil)
// mutating:使得在结构体、枚举遵守协议的时候，可以修改结构体、枚举的成员变量值
struct ConstantIterator: IteratorProtocol { 
    typealias Element = Int
    mutating func next() -> Int? {
        return 1 
    }
}
```

自定义一个sequence

```
import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        for prefix in PrefixSequence(string: "Hello") {
            print(prefix)
        }
    }
}

struct PrefixIterator: IteratorProtocol {
    let string: String
    var offset: String.Index
    init(string: String) {
        self.string = string
        offset = string.startIndex
    }
    mutating func next() -> Substring? {
        guard offset < string.endIndex else { return nil }
        offset = string.index(after: offset)
        print(offset)
        return string[..<offset]
    }
}

struct PrefixSequence: Sequence {
    let string: String
    func makeIterator() -> PrefixIterator {
        return PrefixIterator(string: string)
    }
}


```

#### 不稳定序列
> `Sequence` 的文档非常明确地指出了序列并不保证可以被多次遍历


### 自定义的集合类型

#### 遵守集合类型（Collection）协议

> Collection 将满足一个协议的最小需求已经被写在文档里了，要使你的类型满足 Collection，你至少需要声明以下要求的内容:
> - startIndex和endIndex属性
> - 至少能够读取你的类型中的元素的下标方法
> - 用来在集合索引之间进行步进的index(after:)方法。

```
于是最后，我们需要实现的有:
protocol Collection: Sequence { 
    /// 一个表示集合中位置的类型
    associatedtype Index: Comparable
    /// 一个非空集合中首个元素的位置
    var startIndex: Index { get }
    /// 集合中超过末位的位置---也就是 最后一个有效下标值大1 的位置 
    var endIndex: Index { get }
    /// 返回在给定索引之后的那个索引值 
    func index(after i: Index) -> Index
    /// 访问特定位置的元素
    subscript(position: Index) -> Element { get } }
```

#### 遵守 ExpressibleByArrayLiteral 协议

实现`ExpressibleByArrayLiteral` 能够让用户以他们所熟知的 [value1, value2, etc] 语法创建一个队列，要做到这个非常简单 

```
extension FIFOQueue: ExpressibleByArrayLiteral {
    // 这行可以省略，swift会自动推断
    // 这里的 [1, 2, 3] 并不是一个数组，它只是 一个 “数组字面量”，是一种写法，我们可以用它来创建任意的遵守 ExpressibleByArrayLiteral 的类型。
    typealias ArrayLiteralElement = Element
    init(arrayLiteral elements: Element...) {
        left = elements.reversed()
        right = []
    }
}
```
##### 字面量
> 比如某个枚举值，如果指定了是枚举类型，那么[.one,.two]就是一个枚举值，如果不指定，就是一个数组类型

这里的 [1, 2, 3] 并不是一个数组，它只是 一个 “数组字面量”，是一种写法，我们可以用它来创建任意的遵守 ExpressibleByArrayLiteral 的类型。

在这个字面量里面还包括了其他的字面量类型，比如能够创建任意遵守 ExpressibleByIntegerLiteral 的整数型字面量。这些字面量有 “默认” 的类型，如果你不指明类型，那些 Swift 将假设你想要的就是默认的类 型。正如你所料，
- 数组字面量的默认类型是 Array
- 整数字面量的默认类型是 Int
- 浮点数字面 量默认为 Double 
- 字符串字面量则对应 String。

但是这只发生在你没有指定类型的情况下，举个例子，上面声明了一个类型为 Int 的队列类型，但是如果你指定了其他整数类型的话，你 也可以声明一个其他类型的队列:
```
let byteQueue: FIFOQueue<UInt8> = [1,2,3] 
// FIFOQueue<UInt8>(left: [3, 2, 1], right: [])
```

通常来说，字面量的类型可以从上下文中推断出来。举个例子，下面这个函数可以接受一个从
字面量创建的参数，而调用时所传递的字面量的类型，可以根据函数参数的类型被推断出来:
```
func takesSetOfFloats( oats: Set<Float>) { //...
}
takesSetOfFloats( oats: [1,2,3])
// 这个字  被推断为 Set<Float>，  是 Array<Int>
```

##### 索引
> endIndex 是集合中最后一个元素之后的位置。所以 endIndex 并不是一个有效的下标索引,，你可以用它来创建索引的范围 (someIndex..<endIndex)

### 自定义的集合索引

使用 split(separator:maxSplits:omittingEmptySubsequences:) (当然，这是对英文而言)，将一个 字符串分割成一个个的单词.显然，这样是简单易行的，但是这个方法将会热心地为你计算出整个数组。如果你的字符串非常大，而且你只需要前几个词的话，这么做是相当**低效**的。

```
var str = "Still I see monsters"
str.split(separator: " ") // ["Still", "I", "see", "monsters"]
```
由此，我们要构建一个`Words`集合，它能够让我们不一次性地计算出所有单词，而是可以用**延迟加载**的方式进行迭代。

#### 切片与原集合共享索引
> 集合类型和它的切片拥有相同的索引。只要集合和它的切片在切片被创建后没有改变， 切片中某个索引位置上的元素，应当也存在于原集合中同样的索引位置上。

```
let cities = ["New York", "Rio", "London", "Berlin", "Rome", "Beijing", "Tokyo", "Sydney"]
let slice = cities[2...4] 
cities.startIndex // 0 
cities.endIndex // 8 
slice.startIndex // 2
slice.endIndex // 5
```

### 专门的集合类型
```
// 一个既支持前向又支持后向遍历的集合
→ BidirectionalCollection

// 一个支持高效随机存取索引遍历的集合
→ RandomAccessCollection

// 一个支持下标赋值的集合
→ MutableCollection

// 一个支持将任意子范围的元素用别的集合中的元素进行替换的集合。
→ RangeReplaceableCollection

```
让我们一个一个来进行讨论 

#### 双向索引(BidirectionalCollection)

**BidirectionalCollection** 在前向索引的基础上只增加了一个方法，但是它非常关键，那就是获取上一个索引值的 **index(before:)**。有了这个方法，就可以对应  **first**，给出默认的 **last**属性的 实现了:

```
extension BidirectionalCollection { 
    /// 集合中的最后一个元素。 
    public var last: Element? {
        return isEmpty ? nil : self[index(before: endIndex)] 
    }
}
```

#### 随机存取的集合类型(RandomAccessCollection)
> 随机存取的集合类型可以在常数时间内计算 **startIndex** 和 **endIndex** 之间的距离，这意味着该集合同样能在常数时间内计算出 **count**。



#### 可变集合(MutableCollection)

> **MutableCollection** 允许改变集合中的元素值，但是它不允许改变集合的⻓度或者元素的顺序。后面一点解释了为什么 **Dictionary** 和 **Set** 虽然本身当然是可变的数据结 构，却不满足 **MutableCollection** 的原因。

> 字典和集合都是无序的集合类型，两者中元素的顺序对于使用这两个集合类型的代码来说是没有定义的。不过，即使是这些集合类型，在内部它的元素顺序也是通过实现而唯一确定的。当你想要通过下标赋值的 **MutableCollection** 来改变一个元素时，被改变的元素的索引必须保持 不变，也就是说，这个索引在 **indices** 中的位置必须不能改变。**Dictionary** 和 **Set** 无法保证这 一点，因为它们的 **indices** 指向的是对应元素所在的内部存储，而一旦元素发生变化，这个存 储也会发生改变。


#### 添加或者移除元素(RangeReplaceableCollection)

> RangeReplaceableCollection 是展示协议扩展的强大能力的绝佳例子。你只需要实现一个超 级灵活的 replaceSubrange 方法，协议扩展就可以为你引申出一系列有用的方法

```
→ append(_:)和append(contentsOf:)—将endIndex..<endIndex(也就是说末尾的空范 围) 替换为单个或多个新的元素。
→ remove(at:)和removeSubrange(_:)—将i...i或者subrange替换为空集合。
→ insert(at:)和insert(contentsOf:at:)—将i..<i(或者说在数组中某个位置的空范围)替
   换为单个或多个新的元素。
→ removeAll—将startIndex..<endIndex替换为空集合。

```
如果特定的集合类型能够依据自身为这些函数提供更高效的实现方式，它也可以提供自己的版本，这些版本在使用时将比协议扩展中的默认实现具有更高的优先级。

为了实现起来简单一些，我们会将这些元素再做一
次逆序，然后合并到右侧的数组中，这样我们就可以一次性地对整个范围进行替换了。

```
extension FIFOQueue: RangeReplaceableCollection {
    mutating func replaceSubrange<C: Collection>(_ subrange: Range<Int>,with newElements: C) where C.Element == Element {
        right = left.reversed() + right
        left.removeAll()
        right.replaceSubrange(subrange, with: newElements)
    }
}
```




@ 

