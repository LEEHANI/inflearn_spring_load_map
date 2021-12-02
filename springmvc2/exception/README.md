# 8. 예외 처리와 오류 페이지 

# 서블릿 예외 
## 서블릿 예외 처리 방법 
- Exception(예외) 
- response.sendError(HTTP 상태 코드, 오류 메시지)

# Exception 예외 
## 자바 직접 실행 
- 자바 메인을 실행하면, main이라는 이름의 쓰레드가 실행된다. 
- 실행 도중 예외를 잡지 못하면, 예외 정보를 남기고 해당 쓰레드는 종료된다. 

## 웹 어플리케이션 
- 사용자 request 별로 별도의 쓰레드가 할당되고, 서블릿 컨테이너 안에서 실행된다. 
- 실행 중 예외가 발생했을 때, try ~ catch로 예외를 잡지 한다면?  
- `WAS(여기까지 전파) <- 필터 <- 서블릿 <- 인터셉터 <- 컨트롤러(예외발생)`
- ```
  @GetMapping("/error-ex")
  public void errorEx() {
    throw new RuntimeException("예외 발생!");
  }
  ```
- 실행시켜보면 tomcat이 기본으로 제공하는 오류 화면이 나온다. 
- Exception의 경우 서버 내부에서 처리할 수 없는 오류가 발생한 것으로 생각해서 500을 반환한다.
- 컨트롤러에 없는 url을 호출하면 404 오류 화면을 반환한다. 

# response.sendError(HTTP 상태 코드, 오류 메시지)
- HttpServletResponse가 제공하는 `sendError`로 `서블릿 컨테이너`에게 오류가 발생했다고 전달할 수 있다. 
- 이 메서드를 사용하면 HTTP 상태 코드와 오류 메시지도 추가할 수 있다. 
- ```
  response.sendError(HTTP status code)
  response.sendError(HTTP status code, error message)
  ```
- ```
  @GetMapping("/error-404")
  public void error404(HttpServletResponse response) throws IOException {
    response.sendError(404, "404 오류!"); 
  }
  ```
## sendError 흐름 
- `WAS(sendError) <- filter <- servlet <- interceptor <- controller(response.sendError())`
- `response.sendError()`를 호출하면 `response 내부`에 오류가 발생했다는 `상태를 저장`해준다. 
- 서블릿 컨테이너는 응답 전에 sendError()가 호출됐는지 확인한다. 호출됐으면, 오류 코드에 맞추어 기본 오류 페이지를 보여준다. 

# 서블릿 예외 처리 - 오류 화면 제공 
- 서블릿이 제공하는 기본 오류 화면을 custom 할 수 있다. 
- 과거에는 web.xml로 오류 화면을 등록했다. 
  - ```xml
    <web-app> 
      <error-page>
        <error-code>404</error-code>
        <location>/error-page/404.html</location> 
      </error-page>
      <error-page>
        <error-code>500</error-code>
        <location>/error-page/500.html</location> 
      </error-page>
      <error-page>
        <exception-type>java.lang.RuntimeException</exception-type>
        <location>/error-page/500.html</location> 
      </error-page>
    </web-app>
    ```
- 스프링 부트를 통해서 서블릿 컨테이너를 실행하기 때문에, 스프링 부트가 제공하는 기능으로 서블릿 오류 페이지를 등록할 수 있다. 
- ```java
  //@Component
  public class WebServerCustomizer implements WebServerFactoryCustomizer<ConfigurableWebServerFactory> {

    @Override
    public void customize(ConfigurableWebServerFactory factory) {
        ErrorPage errorPage404 = new ErrorPage(HttpStatus.NOT_FOUND, "/error-page/404");
        ErrorPage errorPage500 = new ErrorPage(HttpStatus.INTERNAL_SERVER_ERROR, "/error-page/500");

        ErrorPage errorPageEx = new ErrorPage(RuntimeException.class, "/error-page/500");

        factory.addErrorPages(errorPage404, errorPage500, errorPageEx);
    }
  }
  ```
- ```
  @RequestMapping("/error-page/404")
  public String errorPage404(HttpServletRequest request, HttpServletResponse response) throws IOException {
    log.info("errorPage 404");
    response.sendError(404, "404오류!");
  }
  ```
- response.sendError(404) 발생 시 /error-page/404 호출
- 그 외에는 /error-page/505 호출. 
- 해당 예외는 그 자식 타입의 오류까지 함께 처리해서 오류 페이지를 보여준다. 

# 서블릿 예외 처리 - 오류 페이지 작동 원리 
- Exception 가 발생해서 서블릿 밖으로 전달되거나 response.sendError() 가 호출되었을 때 오류 페이지를 찾는다.
## Exception 발생 흐름
- `WAS <- filter <- servlet container <- interceptor <- controller`
## sendError 흐름 
- `WAS <- filter <- servlet container <- interceptor <- controller (response.sendError())`
- WAS는 해당 예외를 처리하는 오류 페이지 정보를 확인한다. 
  + `new ErrorPage(RuntimeException.class, "/error-page/500")`
- 확인 후 WAS는 오류 페이지를 출력하기 위해 /error-page/500를 다시 요청한다. 
## sendError 흐름과 오류 페이지 요청 흐름 
- `WAS <- filter <- servlet container <- interceptor <- controller 예외 발생 (response.sendError())`
- `WAS /error-page/500 다시 요청 -> filter -> servlet container -> interceptor -> controller -> View`
- `중요한 점은 웹 브라우저(클라이언트)는 서버 내부에서 이런 일이 일어나는지 전혀 모른다는 점이다. 오직 서버 내부에서 오류 페이지를 찾기 위해 추가적인 호출을 한다.` 

## 정리 
1. 예외가 발생하면 WAS까지 전파된다. 
2. WAS는 오류 페이지 경로를 찾아서 내부에서 오류 페이지를 호출한다. 이떄 오류 페이지 경로로 필터, 서블릿, 인터셉터, 컨트롤러가 모두 다시 호출된다. 

# 서블릿 예외 처리 - 필터 
- 오류가 발생하면 오류 페이지를 출력하기 위해 WAS 내부에서 다시 한번 호출(/error-page/500)이 발생한다.
- 이때 필터, 서블릿, 인터셉터도 모두 다시 호출된다.
- 로그인 인증 체크같은 경우 이미 인증을 완료했는데, `오류 페이지를 호출로 인해 필터, 인터셉터가 다시 또 호출되는 것은 매우 비효율적이다.`
- 결국 클라이언트로 부터 발생한 요청인지, 아니면 오류 페이지를 출력하기 위한 내부 요청인지 구분할 수 있어야 한다. 
- 서블릿은 이런 문제 해결을 위해 `DispatcherType`이라는 추가 정보를 제공한다. 

## DispatcherType 
- 고객이 처음 요청하면 `dispatcherType=REQUEST`이고, 오류 페이지 호출에서 `dispatcherType=ERROR`로 나온다.
- 서블릿은 실제 고객이 요청한 것인지, 서버가 내부에서 오류 페이지를 요청하는 것인지 dispatcherType으로 구분한다. 
- ```java
  public enum DispatcherType {
      FORWARD, //MVC에서 서블릿 -> 서블릿이나 JSP 호출할 때. RequestDispatcher.forward(request, response);
      INCLUDE, //서블릿에서 다른 서블릿이나 JSP의 결과를 포함할 때. RequestDispatcher.include(request, response);
      REQUEST, //클라이언트 요청 
      ASYNC, //서블릿 비동기 호출 
      ERROR //오류 요청 
  }
  ```

## 필터와 DispatcherType
- 필터를 FilterRegistrationBean으로 등록할 때 `filterRegistrationBean.setDispatcherTypes(DispatcherType.REQUEST, DispatcherType.ERROR)` 두 가지 모두 넣으면 클라이언트 요청은 물론이고, 오류 페이지 요청에서도 필터가 호출된다. 
- `기본은 DispatcherType.REQUEST`이며 클라이언트의 요청이 있는 경우에만 필터가 적용된다. 
- 오류 페이지 전용 필터를 적용하고 싶으면 `filterRegistrationBean.setDispatcherTypes(DispatcherType.ERROR)`만 지정해서 필터를 등록하면 된다. 

# 서블릿 예외 처리 - 인터셉터
## 인터셉터 중복 호출 제거
- 앞서 필터의 경우에는 DispatcherType으로 필터를 적용할 지 선택할 수 있었다. 
- 근데 인터셉터는 서블릿이 제공하는 기능이 아니라 스프링이 제공하는 기능이므로 DispatcherType과 무관하게 항상 호출된다. 
- 대신 인터셉터는 경로에 따라서 추가하거나 제외하기 쉽게 되어 있기 때문에, excludePathPatterns를 사용해서 빼줄 수 있다. 
- ```
  @Override
  public void addInterceptors(InterceptorRegistry registry) {
    registry.addInterceptor(new LogInterceptor())
        .order(1)
        .addPathPatterns("/**")
        .excludePathPatterns("/css/**", "*.ico", "/error", "/error-page/**"); //오류 페이지 경로
  } 
  ```
# 전체 흐름 정리 
## /hello 정상 요청 
- `WAS(/hello, dispatcherType=REQUEST) -> filter -> servlet container -> interceptor -> controller -> view`
## /error-ex 오류 요청 
- ```
  1. WAS(/error-ex, dispatcherType=REQUEST) -> filter -> servlet container -> interceptor -> controller -> view
  2. WAS(여기까지 전파) <- filter <- servlet container <- interceptor -> controller(예외발생)
  3. WAS 오류 페이지 확인 
  4. WAS(/error-page/500, dispatchType=ERROR) -> filter(x) -> servlet container -> interceptor(x) -> controller(/error-page/500) -> view
  ```

# 스프링 부트 - 오류 페이지1 
- 지금까지 에외 처리 페이지를 만들기 위해서 WebServerCustomizer를 만들고, ErrorPage를 추가하고, 예외 처리용 컨트롤러 ErrorPageController를 만듦
- `스프링 부트는 위 과정을 모두 기본으로 제공한다.` 
- `BasicErrorController`라는 스프링 컨트롤러를 자동으로 등록하고, /error를 매핑해서 처리하는 컨트롤러다. ErrorMvcAutoConfiguration에서 오류 페이지를 자동으로 등록 
- `resources/template/error`, `resources/static/error` 위치에 뷰 파일을 넣어두면 알아서 인식된다. 

## BasicErrorController의 처리 순서
- `구체적인 것이 덜 구체적인 것보다 우선순위가 높다.`
1. 뷰 템플릿
  - resources/templates/error/500.html
  - resources/templates/error/5xx.html
2. 정적 리소스(static, public) 
  - resources/static/error/400.html
  - resources/static/error/404.html
  - resources/static/error/4xx.html
3. 적용 대상이 없을 때 뷰 이름  
  - resources/templates/error.html 
 
# 스프링 부트 - 오류 페이지2
- BasicErrorController 는 예외 정보를 model에 담아서 뷰에 전달해준다. 
- ```
  * timestamp: Fri Feb 05 00:00:00 KST 2021
  * status: 400
  * error: Bad Request
  * exception: org.springframework.validation.BindException * trace: 예외 trace
  * message: Validation failed for object='data'. Error count: 1 * errors: Errors(BindingResult)
  * path: 클라이언트 요청 경로 (`/hello`)
    ```
- `실무에서는 이것들을 노출하면 안된다! 서버에 로그를 남겨서 로그로 확인해야 한다.`  
