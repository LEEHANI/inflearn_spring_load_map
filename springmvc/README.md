# 6. 스프링 MVC 기본 기능 
## 프로젝트 생성 
- gradle, java 11, spring boot
- packaging: `Jar`
- Dependencies: Spring Web, Thymeleaf, Lombok
### 주의 
- JSP를 사용하지 않기 때문에 Jar를 선택하는 것이 좋다. Jar를 사용하면 항상 내장 서버(톰캣 등)을 사용하고, webapp 경로도 사용하지 않는다. 
- 내장 서버 사용에 최적화 되어 있는 기능이다. 
- `War를 사용하면 내장 서버도 사용가능 하지만, 주로 외부 서버에 배포하는 목적으로 사용`

# 로깅 알아보기 
## 로깅 라이브러리 
- 스프링 부트 라이브러리를 사용하면 스프링 부트 로깅 라이브러리 `spring-boot-starter-logging`이 함께 포함된다. 
- `스프링 부트는 기본적으로 인터페이스 SLF4J, 구현체 Logback를 사용한다.` 
- 로그 라이브러리는 Logback, Log4J, Log4J2 등 많은 라이브러리가 있는데, 그것을 통합해서 인터페이스로 제공하는 것이 바로 SLF4J 라이브러리다. 
## 로그 선언
- `private final Logger log = LoggerFactory.getLogger(getClass())` 
- `private static final Logger log = LoggerFactory.getLogger(Xxx.class)`
- `@Slf4j` 롬복 사용 가능 
## 로그 호출
- log.trace(" trace log={}", name);
- log.debug(" debug log={}", name);
- log.info(" info log={}", name);
- log.warn(" warn log={}", name);
- log.error(" error log={}", name);
## 로그 출력 
```
2021-08-27 11:37:02.437 TRACE 38418 --- [nio-8080-exec-1] hello.springmvc.basic.LogTestController  :  trace log=Spring
2021-08-27 11:37:02.438 DEBUG 38418 --- [nio-8080-exec-1] hello.springmvc.basic.LogTestController  :  debug log=Spring
2021-08-27 11:37:02.438  INFO 38418 --- [nio-8080-exec-1] hello.springmvc.basic.LogTestController  :  info log=Spring
2021-08-27 11:37:02.438  WARN 38418 --- [nio-8080-exec-1] hello.springmvc.basic.LogTestController  :  warn log=Spring
2021-08-27 11:37:02.438 ERROR 38418 --- [nio-8080-exec-1] hello.springmvc.basic.LogTestController  :  error log=Spring
```
## 로그 레벨 
- LEVEL: TRACE > DEBUG > INFO > WARN > ERROR 
- application.properties 에서 로그 레벨 설정 가능
  + 전체 로그레벨 설정(기본 info) `logging.level.root = info` 
  + hello.springmvc 패키지와 그 하위 로그 레벨 설정 `logging.level.hello.springmvc=debug`
### 주의 
log.debug("data="+data)로 사용하면 안된다. "data="+data 문자 더하기 연산이 발생하기 때문이다. 로그 레벨이 info라면 bebug 로그가 출력되지 않지만 더하기 연산은 수행이 된다. 즉, 의미없는 연산이 발생한다. log.debug("data={}", data)로 사용하면 연산이 발생하지 않으므로 제대로 사용해야 한다. 

## 로그 사용시 장점 
- 쓰레드 정보, 클래스 이름 같은 부가 정보를 함께 볼 수 있고, 출력 모양을 조정할 수 있다.
- 로그 레벨에 따라 개발 서버에서는 모든 로그를 출력하고, 운영서버에서는 출력하지 않는 등 로그를 상황에 맞게 조절할 수 있다.
- 시스템 아웃 콘솔에만 출력하는 것이 아니라, 파일이나 네트워크 등, 로그를 별도의 위치에 남길 수 있다. 특히 파일로 남길 때는 일별, 특정 용량에 따라 로그를 분할하는 것도 가능하다.
- 성능도 일반 System.out보다 좋다. (내부 버퍼링, 멀티 쓰레드 등등) 그래서 실무에서는 꼭 로그를 사용해야 한다.

# [요청 매핑](./src/main/java/hello/springmvc/basic/requestmapping/MappingController.java) 
## HTTP 메서드 매핑 
- @RequestMapping
  + HTTP 메서드 모두 허용 GET, HEAD, POST, PUT, PATCH, DELETE
- @PostMapping
- @PutMapping
- @DeleteMapping
- @PatchMapping
## PathVariable 사용 
- ```
  @GetMapping("/mapping/{userId}")
  public String mappingPath(@PathVariable("userId") String data)
  ```
## PathVariable 사용 - 다중 
- ```
  @GetMapping("/mapping/users/{userId}/orders/{orderId}")
  public String mappingPath(@PathVariable String userId, @PathVariable Long orderId)
  ```
## 특정 파라미터 조건 매핑 
- `@GetMapping(value = "/mapping-param", params = "mode=debug")`
- http://localhost:8080/mapping-param?mode=debug
## 특정 헤더 조건 매핑 
- `@GetMapping(value = "/mapping-header", headers = "mode=debug") `
## 미디어 타입 조건 매핑 - HTTP 요청 Content-Type. consume
- `@PostMapping(value = "/mapping-consume", consumes = "application/json") `
## 미디어 타입 조건 매핑 - HTTP 요청 Accept. produce
- `@PostMapping(value = "/mapping-produce", produces = "text/html") `

# [요청 매핑 - API 예시](./src/main/java/hello/springmvc/basic/requestmapping/MappingClassController.java)
- 회원 목록 조회: GET /users
- 회원 등록: POST /users
- 회원 조회: GET /users/{userId}
- 회원수정: PATCH /users/{userId} 
- 회원 삭제: DELETE /users/{userId}

# HTTP 요청 - 기본, 헤더 조회
- 스프링에서 HTTP 헤더 정보 조회 
- HttpServletRequest request, HttpServletResponse response
- HttpMethod httpMethod. HTTP method
- java.util.Locale locale
- @RequestHeader MultiValueMap<String, String> headerMap
  + 모든 HTTP 헤더를 MultiValueMap 형식으로 조회한다.
- @RequestHeader("host") String host,
- @CookieValue(value = "myCookie", required = false) String cookie

## MultiValueMap 
- MAP과 유사한데, 하나의 키에 여러 값을 받을 수 있다. 
- `keyA=value1&keyA=value2`
- ```
  MultiValueMap<String, String> map = new LinkedMultiValueMap(); map.add("keyA", "value1");
  map.add("keyA", "value2");
  //[value1,value2]
  List<String> values = map.get("keyA");
  ```

## 참고
- @Controller 의 사용 가능한 파라미터 목록은 다음 공식 메뉴얼에서 확인할 수 있다.
  + request https://docs.spring.io/spring-framework/docs/current/reference/html/web.html#mvc-ann-arguments
  + response https://docs.spring.io/spring-framework/docs/current/reference/html/web.html#mvc-ann-return-types

# HTTP 요청 파라미터 - 쿼리 파라미터, HTML Form
- 리소스는 /resources/static 아래에 두면 스프링 부트가 자동으로 인식한다.
- Jar 를 사용하면 webapp 경로를 사용할 수 없다. 이제부터 정적 리소스도 클래스 경로에 함께 포함해야한다.
## 스프링이 제공하는 `@RequestParam` 을 사용하면 요청 파라미터를 매우 편리하게 사용할 수 있다.
- @RequestParam("username") String memberName
## HTTP 파라미터 이름이 변수 이름과 같으면 @RequestParam(name="xx") 생략 가능  
- @RequestParam String username
- @RequestParam 애노테이션을 생략하면 스프링 MVC는 내부에서 required=false 를 적용한다.
## 파라미터 필수 여부 - @RequestParam(request = true) 
- 기본값이 파라미터 필수이다. 
- /request-param
  + username이 없으므로 `400 예외`가 발생함.
- /request-param?username=
  + `파라미터 이름만 있고 값이 없는 경우, 빈문자열로 통과된다.` 
- @RequestParam(required = false) int age, /request-param
  + `null을 int에 입력하는 것은 불가능하므로 500 예외 발생함.` 
  + Integer로 바꾸거나 defaultValue 사용 
## 파라미터를 Map으로 조회하기 - @RequestParam Map<String, Object> paramMap    
- 파라미터를 Map, MultiValueMap으로 조회할 수 있다 
- @RequestParam Map
- @ReuqestParam MultiValueMap. 파라미터 값이 여러 개일때 사용 