# 2. 타임리프 - 스프링 통합과 폼


# 타임리프 스프링 통합 
- 타임리프는 스프링 없이도 동작하지만, 스프링과 통합을 위한 다양한 기능을 편리하게 제공한다. 그리고 이런 부분은 스프링으로 백엔드를 개발하는 개발자 입장에서 타임리프를 선택하는 하나의 이유가 된다.
- 기본 메뉴얼: https://www.thymeleaf.org/doc/tutorials/3.0/usingthymeleaf.html
- 스프링 통합 메뉴얼: https://www.thymeleaf.org/doc/tutorials/3.0/thymeleafspring.html 

## 스프링 통합으로 추가되는 기능들
- 스프링의 SpringEL 문법 통합 
- ${@myBean.doSomething()} 처럼 스프링 빈 호출 지원
- 편리한 폼 관리를 위한 추가 속성
- th:object (기능 강화, 폼 커맨드 객체 선택) th:field , th:errors , th:errorclass
- 폼 컴포넌트 기능
  + checkbox, radio button, List 등을 편리하게 사용할 수 있는 기능 지원
- 스프링의 메시지, 국제화 기능의 편리한 통합 스프링의 검증, 오류 처리 통합
- 스프링의 변환 서비스 통합(ConversionService)


# 입력 폼 처리 
- `th:object`: 커맨드 객체를 지정한다. 
- `*{...}`: 선택 변수식. th:object에서 선택한 객체에 접근 
- `th:field`
  + HTML 태그의 id, name, value 속성을 자동으로 처리해준다.
## 렌더링 전
- <input type="text" th:field="*{itemName}" />  
## 렌더링 후 
- <input type="text" id="itemName" name="itemName" th:value="*{itemName}" />
## 사용법 
- `th:object="${item}"`으로 <form>에서 사용할 객체를 지정하면, `th:field="*{itemName}` 식으로 선택 변수식을 적용할 수 있다. 
- ```
   <form action="item.html" th:action th:object="${item}" method="post">
        <div>
            <label for="itemName">상품명</label>
            <input type="text" id="itemName" th:field="*{itemName}" class="form-control" placeholder="이름을 입력하세요">
        </div>
        <div>
            <label for="price">가격</label>
            <input type="text" id="price" th:field="*{price}" class="form-control" placeholder="가격을 입력하세요">
        </div>
        <div>
            <label for="quantity">수량</label>
            <input type="text" id="quantity" th:field="*{quantity}" class="form-control" placeholder="수량을 입력하세요">
        </div>
   </form>
  ```
  
# 체크 박스 단일 
- ```
  <div class="form-check">
    <input type="checkbox" id="open" name="open" class="form-check-input"> 
    <label for="open" class="form-check-label">판매 오픈</label>
  </div>
  ```
- 실행 로그 
  + FormItemController : item.open=true //체크 박스를 선택하는 경우
  + FormItemController : item.open=null //체크 박스를 선택하지 않는 경우
- 체크 박스를 체크하면 HTML Form에서 open=on 이라는 값이 넘어간다. 스프링은 on 이라는 문자를 true 타입으로 변환해준다. (스프링 타입 컨버터가 이 기능을 수행하는데, 뒤에서 설명한다.)
## 주의 - 체크 박스를 선택하지 않을 때
- 체크 박스를 체크하지 않으면 HTML checkbox는 클라이언트에서 서버로 값 자체를 보내지 않는다. 사용자가 의도적으로 체크되어 있던 값을 체크를 해제해도 저장시 아무 값도 넘어가지 않기 때문에, 서버 구현에 따라서 값이 오지 않은 것으로 판단해서 값을 변경하지 않을 수도 있다.  
## 체크 해제를 인식하기 위한 히든 필드 
- 이런 문제를 해결하기 위해서 스프링 MVC는 약간의 트릭을 사용하는데, 히든 필드를 하나 만들어서 체크를 해제한 경우 _open이 전송되어 스프링 MVC는 체크를 해제했다고 판단한다.
  + <input type="hidden" name="_open" value="on"/>
### 체크 박스 체크 
- open=on&_open=on
- 체크 박스를 체크하면 스프링 MVC가 open 에 값이 있는 것을 확인하고 사용한다. 이때 _open 은무시한다.
### 체크 박스 미체크
- _open=on
- 체크 박스를 체크하지 않으면 스프링 MVC가 _open 만 있는 것을 확인하고, open 의 값이 체크되지 않았다고 인식한다.
- 이 경우 서버에서 Boolean 타입을 찍어보면 결과가 null 이 아니라 false 인 것을 확인할 수 있다. log.info("item.open={}", item.getOpen());

## 타임리프 체크 박스 
- 타임리프를 사용하면 체크 박스의 히든 필드와 관련된 부분도 함께 해결해준다.
- ```
  <div class="form-check">
    <input type="checkbox" id="open" th:field="*{open}" class="form-check-input">
    <label for="open" class="form-check-label">판매 오픈</label>
  </div>
  ```
- 타임리프의 th:field 를 사용하면, 값이 true 인 경우 체크를 자동으로 처리해준다.

# 체크 박스 - 멀티 

## @ModelAttribute
- ```
  @ModelAttribute("regions")
  public Map<String, String> regions() {
    Map<String, String> regions = new LinkedHashMap<>(); regions.put("SEOUL", "서울");
    regions.put("BUSAN", "부산");
    regions.put("JEJU", "제주");
    return regions;
  }
  ```
- 이렇게 선언해두면 컨트롤러를 요청할 때 마다 regions에서 반환된 값이 자동으로 모델(model)에 담기게 된다. 

## HTML에 체크 박스 추가 
- ```
  <!-- multi checkbox -->
  <div>
    <div>등록 지역</div>
    <div th:each="region : ${regions}" class="form-check form-check-inline">
        <input type="checkbox"
           th:field="*{regions}"
           th:value="${region.key}"
           class="form-check-input">
        <label th:for="${#ids.prev('regions')}"
            th:text="${region.value}" class="form-check-label">서울</label>
    </div>
  </div>
  ```
- th:for="${#ids.prev('regions')}"
  + 타임리프는 ids.prev(...) , ids.next(...) 을 제공해서 동적으로 생성되는 id 값을 사용할 수 있도록 한다.
## 체크 박스를 여러개 선택   
- item.regions=[SEOUL, BUSAN]   
## 체크 박스를 여러개 선택 x
- item.regions=[]   
