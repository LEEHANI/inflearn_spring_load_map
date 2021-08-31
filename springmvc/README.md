# 6. 스프링 MVC 기본 기능
- HTTP 요청 
  + [쿼리 파라미터, HTML Form](#HTTP-요청-파라미터.-쿼리-파라미터,-HTML-Form)
  + HTTP message body
    + [단순 텍스트](#HTTP-요청-메시지-단순-텍스트) 
    + [JSON](#http-요청-메시지-json)

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

# HTTP 요청 파라미터. 쿼리 파라미터, HTML Form
- 리소스는 /resources/static 아래에 두면 스프링 부트가 자동으로 인식한다.
- Jar 를 사용하면 webapp 경로를 사용할 수 없다. 이제부터 정적 리소스도 클래스 경로에 함께 포함해야한다.
## HTTP 요청 파라미터 - @RequestParam
### 스프링이 제공하는 `@RequestParam` 을 사용하면 요청 파라미터를 매우 편리하게 사용할 수 있다.
- @RequestParam("username") String memberName
### HTTP 파라미터 이름이 변수 이름과 같으면 @RequestParam(name="xx") 생략 가능  
- @RequestParam String username
- @RequestParam 애노테이션을 생략하면 스프링 MVC는 내부에서 required=false 를 적용한다.
### 파라미터 필수 여부 - @RequestParam(request = true) 
- 기본값이 파라미터 필수이다. 
- /request-param
  + username이 없으므로 `400 예외`가 발생함.
- /request-param?username=
  + `파라미터 이름만 있고 값이 없는 경우, 빈문자열로 통과된다.` 
- @RequestParam(required = false) int age, /request-param
  + `null을 int에 입력하는 것은 불가능하므로 500 예외 발생함.` 
  + Integer로 바꾸거나 defaultValue 사용 
### 파라미터를 Map으로 조회하기 - @RequestParam Map<String, Object> paramMap    
- 파라미터를 Map, MultiValueMap으로 조회할 수 있다 
- @RequestParam Map
- @ReuqestParam MultiValueMap. 파라미터 값이 여러 개일때 사용

## HTTP 요청 파라미터 - @ModelAttribute 
- 스프링MVC는 @ModelAttribute가 있으면 다음을 실행한다. 
  + `HelloData` 객체를 생성한다. 
  + 요청 파라미터의 이름으로 `HelloData` 객체의 프로퍼티를 찾는다. 
  + 해당 프로퍼티의 setter를 호출해서 파라미터의 값을 바인딩한다. 조회하면 getter를 호출  
    - 파라미터 이름이 username이면 setUsername() 메서드를 찾아서 값을 입력함 
- age=abc 처럼 숫자가 들어가야 할 곳에 문자를 넣으면 `BindException`이 발생 
- @ModelAttribute는 생략할 수 있다. 근데 @RequestParam도 생략할 수 있으니 혼란이 올 수 있다. 
- 스프링은 해당 생략시 다음과 같은 규칙을 적용한다. 
  + String , int , Integer 같은 단순 타입 = @RequestParam
  + 나머지 = @ModelAttribute (argument resolver 로 지정해둔 타입 외)
  
  
# HTTP 요청 메시지. 단순 텍스트
- HTTP message body에 담긴 데이터를 읽기. 주로 JSON 데이터. POST, PUT, PATCH 메서드. 
- `요청 파라미터와 다르게, HTTP 메시지 바디를 통해 넘어오는 데이터는 @RequestParam, @ModelAttribute를 사용할 수 없다. (HTML Form 요청 제외)`
## v1. HTTP 메시지 바디 데이터는 HttpServletRequest에 InputStream을 사용해 읽을 수 있다. 
- ```
  @PostMapping("/request-body-string-v1")
  public void requestBodyString(HttpServletRequest request, HttpServletResponse response) throws IOException {
    ServletInputStream inputStream = request.getInputStream();
    String messageBody = StreamUtils.copyToString(inputStream, StandardCharsets.UTF_8);
    
    log.info("messageBody={}", messageBody);
    
    response.getWriter().write("ok");
  }
  ```
## v2. 스프링 MVC는 다음 파라미터를 지원한다. InputStream, OutputStream
- `InputStream(Reader): HTTP 요청 메시지 바디의 내용을 직접 조회` 
- `OutputStream(Writer): HTTP 응답 메시지의 바디에 직접 결과 출력` 
- ```
  @PostMapping("/request-body-string-v2")
  public void requestBodyStringV2(InputStream inputStream, Writer reponseWirter) throws IOException {
      String messageBody = StreamUtils.copyToString(inputStream, StandardCharsets.UTF_8);

      log.info("messageBody={}", messageBody);

      reponseWirter.write("ok");
  }
  ```
## v3. 스프링 MVC는 다음 파라미터를 지원한다. HttpEntity
- HttpEntity: HTTP header, body 정보를 편리하게 조회 
  + httpEntity.getBody(), httpEntity.getHeaders()
  + 요청 파라미터 @RequestParam, @ModelAttribute와는 관계 없음 
- HttpEntity는 응답에도 사용 가능
  + 헤더 정보 포함 가능
  + `view 조회 x`  
- HttpEntity를 상속받은 RequestEntity, ResponseEntity도 있다. 
  + RequestEntity
    - HttpMethod, url 정보가 추가, 요청에서 사용
  + ResponseEntity
    - HTTP 상태 코드 설정 가능, 응답에서 사용
    -  return new ResponseEntity<String>("Hello World", responseHeaders, HttpStatus.CREATED)
    
## v4. @RequestBody
- `@RequestBody 를 사용하면 HTTP 메시지 바디 정보를 편리하게 조회할 수 있다.` 
  + 참고로 헤더 정보가 필요하다면 HttpEntity 를 사용하거나 @RequestHeader 를 사용하면 된다.
- 이렇게 메시지 바디를 직접 조회하는 기능은 요청 파라미터를 조회하는 @RequestParam , @ModelAttribute 와는 전혀 관계가 없다.

## @ResponseBody
- @ResponseBody 를 사용하면 응답 결과를 HTTP 메시지 바디에 직접 담아서 전달할 수 있다. 
- 물론 이 경우에도 `view를 사용하지 않는다.`

## 결론 
- `요청 파라미터를 조회하는 기능: @RequestParam , @ModelAttribute`
- `HTTP 메시지 바디를 직접 조회하는 기능: @RequestBody` 


# HTTP 요청 메시지 JSON 
## v1. HttpServletRequest, HttpServletResponse
- HttpServletRequest를 사용해서 직접 HTTP 메시지 바디에서 데이터를 읽어와서 문자로 변환한다. 
- 문자로된 JSON 데이터를 Jackson 라이브러리인 objectMapper를 사용해서 자바 객체로 변환한다. 
- ```
  @PostMapping("/request-body-json-v1")
  public void requestBodyJsonV1(HttpServletRequest request, HttpServletResponse response) throws IOException {
      ServletInputStream inputStream = request.getInputStream();
      String messageBody = StreamUtils.copyToString(inputStream, StandardCharsets.UTF_8);

      log.info("messageBody={}", messageBody);
      HelloData helloData = objectMapper.readValue(messageBody, HelloData.class);
      log.info("username={}, age={}", helloData.getUsername(), helloData.getAge());

      response.getWriter().write("ok");
  }
  ```  
## v2. @RequestBody 
- 이전에 학습했던 @RequestBody를 사용해서 HTTP 메시지에서 데이터를 꺼내고 messageBody에 저장
- 저장된 messageBody 데이터를 objectMapper를 통해서 자바 객체로 변환한다. 
- ```
  @PostMapping("/request-body-json-v2")
  @ResponseBody
  public String requestBodyJsonV2(@RequestBody String messageBody) throws IOException {
      log.info("messageBody={}", messageBody);
      HelloData helloData = objectMapper.readValue(messageBody, HelloData.class);
      log.info("username={}, age={}", helloData.getUsername(), helloData.getAge());

      return "ok";
  }
  ```

## v3. @ResponseBody 객체 반환 
- @ModelAttribute 처럼 한 번에 객체를 반환할 수는 없을까?
- `HTTP 요청시에 content-type이 꼭 application/json 이어야한다.`
- HttpMessageConverter가 동작하여 객체에 값을 넣어준다. 
- `@ResponseBody를 생략하면 @ModelAttribute가 동작하기 때문에 생락하면 안된다.`
  + String, int, Integer 같은 타입은 @RequestParam
  + 나머지는 @ModelAttribute로 동작(argument resolver로 지정해둔 타입)  
- ```
  @PostMapping("/request-body-json-v3")
  public String requestBodyJsonV3(@RequestBody HelloData data) {
    log.info("username={}, age={}", data.getUsername(), data.getAge());
    return "ok";
  }
  ```

## v4. HttpEntity를 사용하여 바디값을 조회할 수도 있다.
- httpEntity.getBody()

## v5. @ResponseBody가 있는 반환 타입에 객체를 리턴할 수 있다.  
```
@PostMapping("/request-body-json-v5")
@ResponseBody
public HelloData requestBodyJsonV5(@RequestBody HelloData helloData) {
    log.info("username={}, age={}", helloData.getUsername(), helloData.getAge());

    return helloData;
}
```

## 정리 
- @RequestBody 요청
  + JSON 요청 HTTP 메시지 컨버터 객체
- @ResponseBody 응답
  + 객체 HTTP 메시지 컨버터 JSON 응답


# HTTP 응답 - 정적 리소스, 뷰 템플릿 
- 정적 리소스
  + 웹 브라우저에 정적인 HTML, css, js 등을 제공하는 `정적 리소스`
- 뷰 템플릿 사용
  + `웹 브라우저에 동적인 HTML을 제공`할 때는 뷰 템플릿 
- HTTP 메시지 사용 
  + HTTP 메시지 바디에 JSON 같은 형식으로 데이터를 전달 

## 정적 리소스 
- 스프링 부트는 클래스패스의 다음 디렉토리에 있는 정적 리소스를 제공한다. 
  + `/static`, `/public`, `/resources`, `/META-INF/resources`
- `src/main/resources 는 리소스를 보관하는 곳이고, 또 클래스패스의 시작 경로이다.` 따라서 다음 디렉토리에 리소스를 넣어두면 스프링 부트가 정적 리소스로 서비스를 제공한다. 
- ex) http://localhost:8080/basic/hello-form.html

## 뷰 템플릿
- 뷰 템플릿을 거쳐서 HTML이 생성되고, 뷰가 응답을 만들어서 전달한다. 
- `일반적으로 HTML을 동적으로 생성하는 용도로 사용`하지만, 다른 것들도 가능하다. 뷰 템플릿이 만들 수 있는 것이라면 뭐든지 가능하다.
- 뷰 템플릿 경로 `src/main/resources/templates`

### String을 반환화는 경우
- ```
  @RequestMapping("/response-view-v2")
  public String responseViewV2(Model model) {
      model.addAttribute("data", "hello!");
      return "response/hello";
  }
  ```
- @ResponseBody가 없으면, "response/hello"로 뷰 리졸버가 실행되어서 뷰를 찾고, 렌더링 한다.
  + 뷰 템플릿 경로인 `src/main/resources/templates`에서 "response/hello"가 있는지 찾는다. 
- @ResponseBody가 있으면, 뷰 리졸버를 실행하지 않고, HTTP 메시지 바디에 문자열이 들어간다. 
### void를 반환하는 경우 (권장x)
- @Controller 를 사용하고, HttpServletResponse , OutputStream(Writer) 같은 HTTP 메시지 바디를 처리하는 파라미터가 없으면 요청 URL을 참고해서 논리 뷰 이름으로 사용

### Thymeleaf 스프링 부트 설정 
- thymeleaf 의존성을 추가하면 스프링 부트가 자동으로 ThymeleafViewResolver와 필요한 스프링 빈들을 등록한다. 
- 그리고 application.properties에 다음 설정도 반영해준다. 
- ```
  spring.thymeleaf.prefix=classpath:/templates/ 
  spring.thymeleaf.suffix=.html
  ```











