

# HTML, HTTP API, CSR, SSR

## 정적 리소스 
- 고정된 HTML 파일, CSS, JS, 이미지, 영상 등 

## HTML 페이지 
- 동적으로 필요한 HTML 파일을 생성해서 전달 
- 요청 --> WAS --> DB --> HTML (화면 렌더링)

## HTTP API 
- 요청 --> WAS --> DB --> Json DATA 
- 주로 JSON 형태로 데이터 통신 
- 앱 클라이언트 -> 서버, 웹 클라이언트 -> 서버, 서버 -> 서버

## 서버 생성 시 고려해야할 사항 
1. 정적 리소스 어캐 제공
2. 동적 HTML 페이지 어캐 제공 
3. HTTP 데이터 어캐 제공 

## SSR - 서버사이드 렌더링
- 서버에서 동적 처리와 함께 화면 페이지까지 제공 
- ex) JSP, 타임리프 
- 요청 -> 서버 -> DB -> HTML 

## CSR - 클라이언트 사이드 렌더링 
- HTML 결과를 자바스크림트를 사용해 웹 브라우저에서 동적을 생성해서 적용 
- ex) React, Vue.js 
- 요청 -> 서버 -> DB -> 자바스크립트 

## WAS
- HTTP 요청 메시지를 연결하고 받아들이는 웹 서버의 역할 
- HttpServletRequest, HttpServletResponse를 생성하고, 서블릿을 호출하는 서블릿 컨테이너의 역할 

# 서블릿
- @ServletComponentScan 서블릿 자동 등록
- @WebServlet의 name 속성을 따로 명시하지 않으면 해당 클래스의 이름을 name 속성으로 사용.
- @WebServlet은 WebServletHandler에 의해 처리되는데 이때 handler가 @WebServlet의 name 속성을 사용하여 BeanDefinition을 만듦. 
- ```
  @WebServlet(name = "helloServlet"), urlPatterns = "/hello")
  public class HelloServlet extends HttpServlet { 
  
    @Override
    public void service(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
       //service logic
    }
  }
  ```
## 서블릿 컨테이너 동작 방식 
- 스프링 부트 -> 내장 톰캣 서버(서블릿 컨테이너) -> HttpServletRequest, HttpServletResponse 생성 -> helloServlet 호출 -> response  
- 참고
  + HTTP 응답에서 Content-Length는 웹 애플리케이션 서버가 자동으로 생성해준다.

# HttpServletRequest 
- `HTTP 요청 메시지를 편리하게 사용할 수 있도록 개발자 대신에 HTTP 요청 메시지를 파싱한다. 그리고 그 결과를 HttpServletRequest 객체에 담아서 제공한다.`
- HttpServletRequest, HttpServletResponse를 사용할 때 가장 중요한 점은 이 객체들이 HTTP 요청 메시지, HTTP 응답 메시지를 편리하게 사용하도록 도와주는 객체라는 점이다
- [HttpServletRequest가 제공하는 메서드로 HTTP 요청 정보들을 조회할 수 있다](./src/main/java/hello/servlet/basic/request/RequestHeaderServlet.java)


# HTTP 요청 데이터 
## GET - 쿼리 파라미터 
- 메시지 바디 없이, URL 쿼리 파라미터에 데이터를 포함해 전달한다. 
- 쿼리 파라미터는 `?`를 시작으로 보낼 수 있다. 추가 파라미터는 `&`로 구분한다. 
  + `http://localhost:8080/request-param?username=hello&age=20`
- 예) 검색, 필터, 페이징등에서 많이 사용
- HttpServletRequest가 제공하는 메서드를 통해 쿼리 파라미터를 편리하게 조회할 수 있다.
  + getParameterNames(): 파라미터 이름 모두 조회 
  + getParamterMap(): 파라미터를 Map으로 조회 
  + String[] getParameterValues(): 이름이 같은 복수 파라미터 조회 
- username=hello&username=hi 처럼 파라미터 이름은 같인데, 값이 중복이라면? 
  + getParameterValues()로 모두 조회할 수 있다. 
  + getParameter()로 조회하면 첫 번째 값을 반환한다. 
- GET URL 쿼리 파라미터 형식으로 클라이언트에서 서버로 데이터를 전달할 때는 HTTP 메시지 바디를 사용하지 않기 때문에 content-type이 없다.
 
## POST - HTML form
- [HTML form으로 서버에 데이터를 전송하는 방법](./src/main/webapp/basic/hello-form.html)
  + ```
    <form action="/request-param" method="post">
        username: <input type="text" name="username" /> age: <input type="text" name="age" /> <button type="submit">전송</button>
    </form>
    ```  
- 생성되는 HTTP 메시지 
  + 요청 URL: http://localhost:8080/request-param
  + content-type: application/x-www-form-urlencoded
  + message body: username=hello&age=20. 메시지 바디에 쿼리 파라미터 형식으로 전달 
- `웹브라우저가 HTTP 메시지 형식을 만들어줌` 
  + ```
    POST /save HTTP/1.1
    Host: localhost:8080
    Content-Type: application/x-www-form-urlencoded
    
    username=kim&age=20
    ```
- 앞서 GET에서 살펴본 쿼리 파라미터 형식과 같기 때문에 request.getParameter()로 조회할 수 있다. 
- `정리하면 request.getParameter() 는 GET URL 쿼리 파라미터 형식도 지원하고, POST HTML Form 형식도 둘 다 지원한다.`
- POST HTML Form 형식으로 데이터를 전달하면 바디로 보내는 것이기 때문에 `content-type을 applicaion/x-www-form-urlencoded로 꼭 지정해야한다.` 
  
## HTTP message body
- HTTP API에서 주로 사용. JSON, XML, TEXT 
- POST, PUT, PATCH
### [HTTP request Data - API 메시지 바디 - 단순 텍스트](./src/main/java/hello/servlet/basic/request/RequestBodyStringServlet.java) 
- HTTP 메시지 바디의 데이터를 InputStream을 사용해서 직접 읽을 수 있다.
- 문자 전송 
  + POST http://localhost:8080/request-body-string content-type: text/plain
  + message body: hello
  + 결과: messageBody = hello
- ```
  ServletInputStream inputStream = request.getInputStream();
  String messageBody = StreamUtils.copyToString(inputStream, StandardCharsets.UTF_8);
  
  System.out.println("messageBody = " + messageBody);
  ```
### [HTTP request Data - API 메시지 바디 - JSON](./src/main/java/hello/servlet/basic/request/RequestBodyJsonServlet.java)
- 문자 전송 
  + POST http://localhost:8080/request-body-json 
  + content-type: application/json
  + message body: {"username": "hello", "age": 20} 
  + 결과: messageBody = {"username": "hello", "age": 20}  
- ```
  ServletInputStream inputStream = request.getInputStream();
  String messageBody = StreamUtils.copyToString(inputStream, StandardCharsets.UTF_8);
  
  HelloData helloData = objectMapper.readValue(messageBody, HelloData.class);
  System.out.println("helloData = " + helloData);
  ```  
  
# HTTP 응답 - HttpServletResponse 
## HttpServletResponse - 기본 사용 방법 
- [HTTP 응답 메시지 생성](./src/main/java/hello/servlet/basic/response/ResponseHeaderServlet.java) 
  + HTTP 응답코드 지정. response.setStatus(HTTPServletResponse.SC_OK)
  + 해더 생성. response.setHeader("Content-Type", "text/plain;charset=utf-8") 
  + 바디 생성. response.getWriter().write("body")
- 편의 기능 제공  
  + content-type. response.setContentType("text/plain)
  + 쿠키. response.addCookie(cookie)
  + Redirect. response.sendRedirect("/basic/hello-form.html")

## [HttpServletReponse 응답 데이터 - 단순 텍스트, HTML](./src/main/java/hello/servlet/basic/response/ResponseHtmlServlet.java)
- `content-type=text/html`, `charset=utf-8` 지정 필요 
  + response.setContentType("text/html"), response.setCharacterEncoding("utf-8")
- ```
  PrintWriter writer = response.getWriter();
  writer.println("<html>");
  writer.println("<body>");
  writer.println("   <div>안녕?</div>");
  writer.println("</body>");
  writer.println("</html>");
  ``` 
  
## [HttpServletReponse 응답 데이터 - API JSON](./src/main/java/hello/servlet/basic/response/ResponseJsonServlet.java) 
- `content-type=application/json`, `charset=utf-8` 지정 필요 
  + response.setContentType("application/json"), response.setCharacterEncoding("utf-8")
- Jackson 라이브러리로 JSON 문자로 변경. objectMapper.writerValueAsString(object)
- ```
  String result = objectMapper.writerValueAsString(helloData);
  response.getWriter().writer(result);
  ```