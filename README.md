<a href='https://github.com/popor/mybox'> MyBox </a>

# PoporFMDB

[![CI Status](https://img.shields.io/travis/wangkq/PoporFMDB.svg?style=flat)](https://travis-ci.org/wangkq/PoporFMDB)
[![Version](https://img.shields.io/cocoapods/v/PoporFMDB.svg?style=flat)](https://cocoapods.org/pods/PoporFMDB)
[![License](https://img.shields.io/cocoapods/l/PoporFMDB.svg?style=flat)](https://cocoapods.org/pods/PoporFMDB)
[![Platform](https://img.shields.io/cocoapods/p/PoporFMDB.svg?style=flat)](https://cocoapods.org/pods/PoporFMDB)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

PoporFMDB is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'PoporFMDB'
```

1.02
getCreateSQLS:with:
该方法检测实体是否包含id,如果包含就不创建自增id INTEGER

1.03
getCreateSQLS getInsertSQLS 针对有id类型的sql优化,

1.04
部分函数增加 返回执行结果

1.05
addPlistKey 增加检查 key 是否重复

1.07
允许修改db path

1.08
移除了 PoporFMDB 的 + (BOOL)updateEntity:(id)entity key:(NSString *)key equal:(id)value where:(NSString *)whereKey equal:(id)whereValue, 内部一个给entity赋值的多余操作.

+ (BOOL)updateEntity:(id)entity  keyS:(NSArray *)keyArray equalS:(NSArray *)valueArray whereS:(NSArray *)whereKeyArray;
允许update的时候,修改多个参数,where也允许多个参数, demo 中包含了用法.



## Author

wangkq, 908891024@qq.com

## License

PoporFMDB is available under the MIT license. See the LICENSE file for more info.
