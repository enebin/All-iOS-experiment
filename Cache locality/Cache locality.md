# Cache locality

## 캐시 지역성

---

캐시 지역성은 프로세서가 최근에 액세스한 데이터와 메모리 주소가 ‘공간적’으로 가깝거나 마지막으로 액세스한 시점과 ‘시간적’으로 가까운 데이터에 액세스하는 경향을 나타내는 용어입니다.

### 종류

캐시 지역성은 시간적 지역성과 공간적 지역성의 두 가지 유형이 있습니다.

- **공간적 지역성**
    - 공간적 지역성은 특정 메모리 주소의 데이터에 액세스하면 가까운 시일 내에 인근 메모리 주소에도 액세스할 가능성이 높은 경항을 말합니다.
    - 이는 데이터가 배열이나 구조체와 같이 인접한(contagious) 메모리 위치에 저장되는 경우가 많기 때문입니다.
    - 가까운 메모리 위치의 데이터를 캐싱하면 프로세서는 필요할 때 빠르게 액세스할 수 있으므로 성능이 향상됩니다.
- **시간적 지역성**
    - 시간적 지역성은 특정 시점에 데이터에 액세스하면 가까운 시일 내에 해당 주소를 다시 액세스할 가능성이 높은 경향을 말합니다. 즉, 최근에 액세스한 데이터는 곧 다시 액세스할 확률이 높습니다.
    - 최근에 액세스한 데이터를 캐시에 보관하면 프로세서는 필요할 때 빠르게 액세스할 수 있으므로 성능이 향상됩니다.

개발자는 시간적, 공간적 지역성를 모두 활용하는 프로그램을 설계함으로써 보다 효율적이고 빠른 성능의 소프트웨어를 만들 수 있습니다. 프로세서가 RAM과 같이 느린 메모리에서 데이터를 불러오는 시간을 줄이고, 더 빠른 캐시 메모리에 이미 있는 데이터를 사용할 수 있기 때문입니다.

## 예시

---

[신비로운 다음 코드](https://github.com/enebin/All-iOS-experiment/blob/main/Cache%20locality/CacheLocalityTests.swift)를 보고 캐시의 공간 지역성을 직접 경험해봅니다.

```swift
class SpatialLocalityTests: XCTestCase {
    var array: [[Int]]!
    let numRows = 10_000
    let numColumns = 10_000

    override func setUp() {
        super.setUp()
        array = Array(repeating: Array(repeating: 0, count: numColumns), count: numRows)
    }

    override func tearDown() {
        array = nil
        super.tearDown()
    }

    func accessArrayRowWise(array: inout [[Int]]) {
        for row in 0..<array.count {
            for column in 0..<array[row].count {
                array[row][column] = row * column
            }
        }
    }

    func accessArrayColumnWise(array: inout [[Int]]) {
        for column in 0..<array[0].count {
            for row in 0..<array.count {
                array[row][column] = row * column
            }
        }
    }

    func testSpatialLocality() {
        var current = CFAbsoluteTimeGetCurrent()
        accessArrayRowWise(array: &array)
        
        print("Contagious caching: ", CFAbsoluteTimeGetCurrent() - current)
        
        
        current = CFAbsoluteTimeGetCurrent()
        accessArrayColumnWise(array: &array)
        
        print("Uncontagious caching: ", CFAbsoluteTimeGetCurrent() - current)
    }
}
```

### 전제

1. 10,000 x 10,000($= 10^8$) 개의 요소를 가진 행렬의 각 요소를 조회한 후 인덱스를 곱셈하는 단순한 연산을 진행합니다.
2. `accessArrayRowWise`는 행-열의 순서로 `accessArrayColumnWise`는 열-행의 순서로 조회합니다.

### 결과

아래 결과는 5회 실행 후 평균으로 얻은 값입니다

```swift
accessArrayRowWise(contagious):  21.896546006202698
accessArrayColumnWise(uncontagious):  27.75752902030945
```

- `accessArrayColumnWise`가 `accessArrayRowWise`에 비해 약 6초 가량 느린 것을 확인할 수 있으며 약 28.5%의 성능 저하를 보입니다.

### 이유

이에 대해서는 Swift에서 어레이를 비롯한 자료구조가 캐시에 적재되는 과정을 이해할 필요가 있습니다.

간단하게 정리하면 어레이는 정책에 의해 인접한 데이터가 *캐시라인* 단위로 캐시에 로딩되며, 이 경우 행의 일부가 로딩되어 행 단위로 참조를 하는 두 번째 코드의 경우 이전에 로드 된 열을 비우고 다시 적재하는 과정이 더해져 미스율이 높아지고 성능이 낮아지는 것입니다.

## 캐시 로딩 정책

---

iOS 및 macOS에서 Swift를 사용하여 애플리케이션을 개발할 때는 일반적으로 고수준에서 추상화 된 API를 통해 작업을 수행합니다. 따라서 개발자가 직접적으로 캐시를 컨트롤 해야 할 경우는 흔하지 않습니다. 다만 깊은 이해를 위해 배후 동작을 알아보도록 합시다.

### 캐시에 대해

iOS 또는 macOS의 배열 저장소에는 일반적으로 CPU 캐시와 주 메모리(RAM)가 포함됩니다.

- CPU 캐시는 주 메모리에 비해 더 작고 빠른 메모리입니다. 자주 사용하는 데이터를 CPU 곁에서 저장 및 유지해 액세스 시간을 줄여줍니다.
- 캐시는 레벨(L1, L2, L3)로 나뉘며, L1이 가장 빠르고 CPU와 가장 가깝습니다. 운영 체제와 하드웨어가 함께 캐싱을 관리합니다.

### 캐시 로딩에 관한 정보 몇 가지

다음은 캐시에 관한 몇 가지 동작에 대한 설명입니다:

- **연속(contagious) 메모리**
    
    Swift의 배열은 연속된 메모리 블록에 저장됩니다. 이는 캐시의 공간적 지역성을 이용하기 위함입니다.
    
- **캐시 라인**
    
    캐시 메모리는 캐시 라인이라고 하는 고정된 크기의 청크로 나뉘며, 일반적으로 64바이트입니다. 
    
    CPU는 주 메모리에서 데이터를 가져올 때 요청된 데이터가 포함된 캐시 라인 전체를 가져옵니다. 따라서 동일한 캐시 라인에 속하는 배열 요소에 더 빠르게 액세스할 수 있습니다. 역시 캐시 지역성을 이용하기 위함입니다.
    
- **집합 연관 캐시**
    
    캐시는 세트(set)와 웨이(way)로 구성됩니다. 
    
    세트는 캐시 라인의 그룹이며, 웨이는 세트 내의 단일 캐시 라인입니다. 캐시의 연관성(associativity)은 각 세트에 몇 개의 웨이가 있는지 정의합니다. 연관성이 높은 캐시는 삭제되지 않고 계속 존재하므로서 배열의 캐시 적중률이 향상될 수 있습니다.
    
- **캐시 삭제 정책**
    
    캐시가 가득 차서 새 데이터를 로드해야 하는 경우 캐시 삭제 대상을 결정하는 것이 중요합니다. 일반적으로 LRU 및 FIFO 등을 사용합니다.
    

## 정리

---

캐시 지역성은 시간적 지역성과 공간적 지역성의 두 가지 유형이 있습니다. **공간적 지역성**은 특정 메모리 주소의 데이터에 액세스하면 가까운 시일 내에 인근 메모리 주소에도 액세스할 가능성이 높은 경항을, **시간적 지역성**은 특정 시점에 데이터에 액세스하면 가까운 시일 내에 해당 주소를 다시 액세스할 가능성이 높은 경향을 말합니다. 

OS 및 macOS에서 Swift를 사용하여 애플리케이션을 개발할 때는 일반적으로 고수준에서 추상화 된 API를 통해 작업을 수행하며 **연속(contagious) 메모리, 캐시 라인, 집합 연관 캐시, 캐시 삭제 정책** 등을 이용해 캐시를 관리합니다.

## 참고
[캐시](https://ko.wikipedia.org/wiki/캐시)

[💵 캐시가 동작하는 아주 구체적인 원리: 하드웨어로 구현한 해시 테이블](https://parksb.github.io/article/29.html)