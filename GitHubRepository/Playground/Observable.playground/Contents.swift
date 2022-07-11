import UIKit
import RxSwift
import Foundation

print("----Just----")
Observable<Int>.just(1)
  .subscribe(onNext: { print($0) })

print("----Of1----")
Observable<Int>.of(1, 2, 3, 4, 5)
  .subscribe(onNext: { print($0) })

print("----Of2----")
Observable.of([1, 2, 3, 4, 5]) // just 와 동일
  .subscribe(onNext: { print($0) })

print("----from----")
Observable.from([1, 2, 3, 4, 5]) // array 형태만 받음
  .subscribe(onNext: { print($0) })


print("----subscribe1----")
Observable.of(1, 2, 3)
  .subscribe {
    print($0)
  }

print("----subscribe2----")
Observable.of(1, 2, 3)
  .subscribe {
    if let element = $0.element {
      print(element)
    }
  }

print("----subscribe3----")
Observable.of(1, 2, 3)
  .subscribe(onNext:{
    print($0)
  })

print("----empty----") // 즉시 종료할수 있는
Observable.empty()
  .subscribe {
    print($0)
  }


print("----never----")
Observable.never()
  .debug()
  .subscribe(onNext: {
    print($0)
  }, onCompleted: {
    print("Complete")
  })


print("----range----")
Observable.range(start: 1, count: 9)
  .subscribe(onNext: {
    print("2 * \($0) = \(2 * $0)")
  })


print("----dispose----")
Observable.of(1, 2, 3)
  .subscribe {
    print($0)
  }
  .dispose()

print("----disposeBag----")

var disposeBag = DisposeBag()

Observable.of(1, 2, 3)
  .subscribe {
    print($0)
  }
  .disposed(by: disposeBag)

print("----create1----")

Observable.create { observer -> Disposable in
  
  observer.onNext(1)
  observer.onCompleted()
  observer.onNext(2)
  
  return Disposables.create()
}
.subscribe {
  print($0)
}
.disposed(by: disposeBag)


print("----create2----")

enum MyError: Error {
  case anError
}

Observable<Int>.create { observer -> Disposable in
  observer.onNext(1)
  observer.onError(MyError.anError)
  observer.onCompleted()
  observer.onNext(2)
  return Disposables.create()
}
.subscribe(
  onNext: {
    print($0)
  },
  onError: {
    print($0.localizedDescription)
  },
  
  onCompleted: {
    print("completed")
  },
  
  onDisposed: {
    print("disposed")
  }
)
.disposed(by: disposeBag)


print("----defferd1----")

Observable.deferred {
  Observable.of(1, 2, 3)
}
.subscribe {
  print($0)
}
.disposed(by: disposeBag)


print("----defferd2----")

var 뒤집기: Bool = false

let factory: Observable<String> = Observable.deferred {
  뒤집기 = !뒤집기
  
  if 뒤집기 {
    return Observable.of("👋🏼")
  }else {
    return Observable.of("👎")
  }
}

for _ in 0...3 {
  factory.subscribe(onNext: {
    print($0)
  })
  .disposed(by: disposeBag)
}


