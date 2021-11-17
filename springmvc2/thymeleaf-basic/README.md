# 1. 타임리프 - 기본 기능



# 타임리프 

## 타임리프 특징 
### 서버 사이드 HTML 렌더링 (SSR)
- 백엔드 서버에서 HTML을 동적으로 렌더링 하는 용도 
### `네츄럴 템플릿`
- 타임리프는 순수 HTML을 최대한 유지하는 특징이 있다. 
- HTML 파일을 직접 열어도 내용을 확인할 수 있고, 서버를 통해 뷰 템플릿을 거치면 동적으로 변경된 결과를 확인할 수 있다. 
- `순수 HTML을 유지하면서 뷰 템플릿도 사용할 수 있는 타임리프 특징을 네츄럴 템플릿`이라 한다. 
### 스프링 통합 지원 
- 스프링과 자연스럽게 통합되고, 스프링의 다양한 기능을 편리하게 사용할 수 있게 지원

### 타입리프 사용 선언 
- 사용 선언 `<html xmlns:th="http://www.thymeleaf.org">`

# 텍스트 - text, utext
- HTML의 콘텐츠에 데이터를 출력할 때는 `th:text`를 사용하면 된다.
  + `<span th:text="${data}">`
- HTML 태그 속성이 아니라 직접 데이터를 출력하고 싶으면 `[[...]]`를 사용하면 된다.
  + `<li>[[${data}]]</li>`

## Escape 
- HTML 문서는 <, > 같은 특수 문자를 기반으로 정의된다. 따라서 뷰 템플릿으로 HTML화면을 생성할 때, 특수 문자가 있는 것을 주의해서 사용해야 한다. 
- `<b>` 태그를 사용해서 Spring!이라는 단어가 진하게 나오도록 해보자 
  + model.addAttribute("data", "Hello <b>Spring!</b>");
  + [<span th:text="${data}"></span> 소스보기를 하면 < 부분이 `&lt;`로 변경되어 있는걸 볼 수 있다.](./src/main/resources/templates/basic/text-unescape.html)  

## HTML 엔티티
- 웹 브라우저는 < 를 HTML 태그의 시작으로 인식한다. < 를 태그의 시작이 아니라 문자로 표현할 수 있는 방법이 필요한데, 이것을 HTML 엔티티라 한다.
- HTML에서 사용하는 특수 문자를 HTML 엔티티로 변경하는 것을 이스케이프라 한다.  
- 타임리프는 `th:text, [[...]]를 기본 적으로 이스케이프를 제공`한다.
- 이스케이프 기능을 사용하지 않으려면? 
  + th:text -> `th:utext`
  + [[...]] -> `[(...)]`
- `escape를 사용하지 않아서 HTML이 정상 렌더링 되지 않는 문제가 발생할 수 있으니, escape를 기본으로 하고 꼭 필요한 때만 unescape를 사용하자.`

# [변수 - SpringEL](./src/main/resources/templates/basic/operation.html)
- 변수 표현식 `${...}`
- Object
  + ${user.username}
  + ${user['username']
  + ${user.getUsername()}
- List
  + ${users[0].username}
  + ${users[0]['username']}
  + ${users[0].getUsername()}
- Map 
  + ${userMap['userA'].username} 
  + ${userMap['userA']['username']}
  + ${userMap['userA'].getUsername()}

## 지역 변수 선언
- 태그 안에서만 사용 가능. `th:with`로 선언  
- ```
  <div th:with="first=${users[0]}">
      <p>처음 사람의 이름은 <span th:text="${first.username}"></span></p>
  </div>
  ```

# 기본 객체들 
- 타임리프는 기본 객체들을 제공한다. 
  + ${#request}
  + ${#response}
  + ${#session}
  + ${#servletContext}
  + ${#locale}
- request는 HttpServletRequest 객체가 그대로 제공되는 것이기 때문에, 파라미터를 조회하려면 request.getParameter("data")로 접근해야 하지만, 편의 객체를 사용하면 이런 수고를 덜어도 된다.
- HTTP 요청 파라미터 접근 `param`
  + http://localhost:8080/basic/basic-objects?paramData=HelloParam 
  + ${param.paramData}
- HTTP 세션 접근 `session`
  + ${session.sessionData}
- 스프링 빈 접근 `@` 
  + ${@helloBean.hello('spring!')} 

# 유틸리티 객체와 날짜  
- 타임리프는 문자, 숫자, 날짜, URI등을 편리하게 다루는 다양한 유틸리티 객체들을 제공한다.
  + #message : 메시지, 국제화 처리
  + #uris : URI 이스케이프 지원
  + #dates : java.util.Date 서식 지원 
  + #calendars : java.util.Calendar 서식 지원 
  + #temporals : 자바8 날짜 서식 지원
  + #numbers : 숫자 서식 지원
  + #strings : 문자 관련 편의 기능
  + #objects : 객체 관련 기능 제공
  + #bools : boolean 관련 기능 제공
  + #arrays : 배열 관련 기능 제공
  + #lists , #sets , #maps : 컬렉션 관련 기능 제공 
  + #ids : 아이디 처리 관련 기능 제공, 뒤에서 설명
- 자바8 날짜인 LocalDate, LocalDateTime, Instant를 사용하려면 추가 라이브러리가 필요하다. 스프링 부트 타임리프를 사용하면 해당 라이브러리가 자동으로 추가되고 통합된다.
  + `thymeleaf-extras-java8time`
  + [`<span th:text="${#temporals.format(localDateTime, 'yyyy-MM-dd HH:mm:ss')}"></span>`](./src/main/resources/templates/basic/date.html)
  
# URL 링크 @{...} 
## 단순한 URL
- @{/hello} -> http://localhost:8080/hello
## 쿼리 파라미터
- @{/hello(param1=${param1}, param2=${param2})} -> /hello?param1=data1&param2=data2
- ()안에 있는 부분은 쿼리 파라미터로 처리된다.   
## 경로 변수
- @{/hello/{param1}/{param2}(param1=${param1}, param2=${param2})} -> /hello/data1/data2
- URL 경로상에 변수가 있으면 () 부분은 경로 변수로 처리된다.
## 경로 변수 + 쿼리 파라미터
- @{/hello/{param1}(param1=${param1}, param2=${param2})} -> /hello/data1?param2=data2
- 경로 변수와 쿼리 파라미터를 함께 사용할 수 있다.

# 리터럴 
- 리터럴은 소스 코드상에 고정된 값을 말하는 용어
  + String a = "Hello"
- 타임 리프에서 문자 리터럴은 항상 `'`로 감싸야 한다. `<span th:text="'hello'">`
- 타임리프는 다음과 같은 리터럴이 있다. 
  + 문자: 'hello'
  + 숫자: 10 
  + 불린: true, false
  + null: null

## A-Z, a-z, 0-9, [], ., -, _ 인 경우 작은 따옴표 생략 가능 
- `A-Z, a-z, 0-9, [], ., -, _` 인 경우 작은 따옴표를 생략할 수 있다. `<span th:text="hello">`
- 근데, 공백이 있으면 하나의 토큰으로 인식되지 않으므로 작은 따옴표(`'`)로 감싸줘야한다. 혹은 리터럴 대체(`|`)를 사용
  + `<span th:text="hello world!"></span>` -> `<span th:text="'hello world!'"></span>` 

# 연산 
- 타임리프 연산은 자바와 크게 다르지 않다.
- HTML안에서 사용하기 때문에 HTML 엔티티를 사용하는 부분만 주의하자.
## 비교연산
- `>` (gt), `<` (lt), `>=` (ge), `<=` (le), `!` (not), `==` (eq), `!=` (neq, ne)

# 속성 값 설정 
- 타임리프는 주로 HTML 태그에 `th:*` 속성을 지정하는 방식으로 동작한다. `th:* 로 속성을 적용하면 기존 속성을 대체한다.` 기존 속성이 없으면 새로 만든다.
  + `<input type="text" name="mock" th:name="userA" />`
  + 순수 HTML: `<input type="text" name="mock" />`
  + 타임리프 렌더링 후: `<input type="text" name="userA" />`

## 속성 추가 
- th:attrappend : 속성 값의 뒤에 값을 추가
- th:attrprepend : 속성 값의 앞에 값을 추가
- th:classappend : class 속성에 추가

## checked 처리 
- HTML에서는 `<input type="checkbox" name="active" checked="false" />` true인지 false인지 상관없이 checked 처리가 되어버린다.
- 타임리프의 th:checked 속성이 이를 해결해준다. 
  + 체크 박스 표시 X: `<input type="checkbox" name="active" th:checked="false" />`
  + 체크 박스 표시 O: `<input type="checkbox" name="active" th:checked="true" />`

# 반복
- 타임리프에서 반복은 `th:each` 를 사용한다. 
- ```html
  <tr th:each="user : ${users}">
    <td th:text="${user.username}">username</td> <td th:text="${user.age}">0</td>
  </tr>
  ```

## 반복 상태 유지
- ```html
  <tr th:each="user, userStat : ${users}">
    <td th:text="${userStat.index}">username</td> 
    <td th:text="${userStat.even}">0</td>
  </tr>
  ```
- index : 0부터 시작하는 값
- count : 1부터 시작하는 값
- size : 전체 사이즈
- even , odd : 홀수, 짝수 여부( boolean ) 
- first , last :처음, 마지막 여부( boolean ) 
- current : 현재 객체


# 조건부 평가
## if, unless
- 타임리프는 해당 조건이 맞지 않으면 태그 자체를 렌더링하지 않는다.
- 만약 다음 조건이 false 인 경우 <span>...<span> 부분 자체가 렌더링 되지 않고 사라진다. `<span th:text="'미성년자'" th:if="${user.age lt 20}"></span>`

## switch
- ```html
  <td th:switch="${user.age}">
    <span th:case="10">10살</span>
    <span th:case="20">20살</span>
    <span th:case="*">기타</span>
  </td>
  ```
- * 은 만족하는 조건이 없을 때 사용하는 디폴트이다.

# 주석 
## 표준 HTML 주석
- 자바스크립트의 표준 HTML 주석은 타임리프가 렌더링 하지 않고, 그대로 남겨둔다.
- ```
  <!--
  <span th:text="${data}">html data</span> 
  -->
  ```
## 타임리프 파서 주석
- 타임리프 파서 주석은 타임리프의 진짜 주석이다. 렌더링에서 주석 부분을 제거한다.
- ```
  <!--/* [[${data}]] */-->
  
  <!--/*-->
  <span th:text="${data}">html data</span> 
  <!--*/-->
  ```
## 타임리프 프로토타입 주석
- HTML 파일을 그대로 열어보면 주석처리가 되지만, 타임리프를 렌더링 한 경우에만 보이는 기능이다.
- ```
  <!--/*/
  <span th:text="${data}">html data</span> 
  /*/-->
  ```

# 블록 
- `<th:block>` 은 HTML 태그가 아닌 타임리프의 유일한 자체 태그다.
- 타임리프의 특성상 HTML 태그안에 속성으로 기능을 정의해서 사용하는데, 사용하기 애매한 경우에 사용하면 된다. <th:block> 은 렌더링시 제거된다.

# 자바스크립트 인라인
- 자바스크립트에서 타임리프를 편리하게 사용할 수 있는 자바스크립트 인라인 기능을 제공
- 사용 선언 <script th:inline="javascript">

## 텍스트 렌더링 
- 인라인을 사용하지 않으면 렌더링 후 `"`가 없기 때문에 자바스크립트 오류가 발생한다. 인라인을 사용하면 렌더링 시 `"`를 포함해준다.
- var username = [[${user.username}]]
  + 인라인 사용 전: var username = userA;
  + 인라인 사용 후: var username = "userA";

## 자바스크립트 내추럴 템플릿
- 자바스크립트 인라인 기능을 사용하면 주석을 활용해서 내추럴 템플릿 기능을 사용할 수 있다.
- var username2 = /*[[${user.username}]]*/ "test username"; 
  + 인라인 사용 전: var username2 = /*userA*/ "test username"; => 내추럴 템플릿 기능이 동작하지 않고, 심지어 렌더링 내용이 주석처리 되어 버림.
  + 인라인 사용 후: var username2 = "userA";

## 객체 
- 타임리프의 자바스크립트 인라인 기능을 사용하면 객체를 JSON으로 자동으로 변환해준다.
- var user = [[${user}]];
  + 인라인 사용 전: var user = BasicController.User(username=userA, age=10);  -> toString()
  + 인라인 사용 후: var user = {"username":"userA","age":10};
## each
- 자바스크립트 인라인은 each를 지원하는데, 다음과 같이 사용한다.
- ```
  <!-- 자바스크립트 인라인 each --> 
  <script th:inline="javascript">

    [# th:each="user, stat : ${users}"]
    var user[[${stat.count}]] = [[${user}]]; 
    [/]

  </script>
  ```
- ```
  <script>
  var user1 = {"username":"userA","age":10};
  var user2 = {"username":"userB","age":20};
  var user3 = {"username":"userC","age":30};
  </script>
  ```

# 템플릿 조각
- 타임리프는 템플릿 조각과 레이아웃 기능을 지원한다.
- ex) `<div th:insert="~{template/fragment/footer :: copy}"></div>`
- template/fragment/foot :: copy
  + template/fragment/foot.html 템플릿에 있는 th:fragment="copy" 부분을 가져와서 사용한다는 의미 
  + ```
    <footer th:fragment="copy">
       푸터 자리 입니다. 
    </footer>
    ```

## 부분 포함 insert
- `<div th:insert="~{template/fragment/footer :: copy}"></div>`
- th:insert를 사용하면 현재 태그 내부에 추가한다. 
- ```
  <div>
    <footer>
      푸터 자리 입니다.
    </footer>
  </div>
  ```

## 부분 포함 replace
- `<div th:replace="~{template/fragment/footer :: copy}"></div>`
- th:replace를 사용하면 현재 태그를 대체한다.
- ```
  <footer>
    푸터 자리 입니다.
  </footer>
  ```

## 파라미터 사용 
- 파라미터를 전달해서 동적으로 조각을 렌더링 할 수도 있다. 
- ` <div th:replace="~{template/fragment/footer :: copyParam ('데이터1', '데이터2')}"></div>`
- ```html
  <footer th:fragment="copyParam (param1, param2)">
    <p>파라미터 자리 입니다.</p>
    <p th:text="${param1}"></p> 
    <p th:text="${param2}"></p>
  </footer>
  ```


# 템플릿 레이아웃1 
- 이전에는 일부 코드 조각을 가지고와서 사용했다면, 이번에는 개념을 더 확장해서 코드 조각을 레이아웃에 넘겨서 사용하는 방법에 대해서 알아보자.
- 예를 들어서 `<head>` 에 공통으로 사용하는 css, javascript 같은 정보들이 있다. 공통으로 사용하기 위해 한 곳에 모아두고, 각 페이지마다 필요한 정보를 더 추가해서 사용할 수 있다. 
- ```
  <html xmlns:th="http://www.thymeleaf.org">
  <head th:fragment="common_header(title,links)">

    <title th:replace="${title}">레이아웃 타이틀</title>

    <!-- 공통 -->
    <link rel="stylesheet" type="text/css" media="all" th:href="@{/css/awesomeapp.css}">
    <link rel="shortcut icon" th:href="@{/images/favicon.ico}">
    <script type="text/javascript" th:src="@{/sh/scripts/codebase.js}"></script>

    <!-- 추가 -->
    <th:block th:replace="${links}"/>

  </head>
  ```
- `<head th:replace="template/layout/base :: common_header(~{::title},~{::link})">`
  + head 부분이 template/layout/base로 대체될때, base.html + 전달한 파라미터 title, link가 대체/추가 되어 생성된다. 
  + base.html에 가보면 이 부분이 `<head th:fragment="common_header(title,links)">` 다른 페이지에서 전달 받은 값으로 대체된다. 
  + base.html의 title인 `레이아웃 타이틀`이 아닌, 전달받은 title 파라미터 값인 `메인 타이틀`로 대체된다.
  + base.html에 선언된 공통 부분(link, script)은 그대로 들어가고 추가적으로 전달받은 links 태그들이 선언된다.

# 템플릿 레이아웃2
- 템플릿 레아이웃1처럼 헤더부분만 적용할 수도 있고 html 전체를 적용할 수도 있다. 
