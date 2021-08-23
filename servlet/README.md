

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
  
# 서블릿으로 회원 관리 웹 애플리케이션 만들기 
- [회원 등록](./src/main/java/hello/servlet/web/servlet/MemberSaveServlet.java)
- [회원 목록](./src/main/java/hello/servlet/web/servlet/MemberListServlet.java)
## 템플릿 엔진으로 
- 서블릿 덕분에 동적인 HTML 문서를 만들 수 있었다. 정적인 HTML 문서라면 화면이 계속 달라지는 회원의 저장 결과라던가, 회원 목록 같은 동적인 HTML을 만드는 일은 불가능 할 것이다.
  + ```
    String username = request.getParameter("username");
    int age = Integer.parseInt(request.getParameter("age"));

    Member member = new Member(username, age);
    memberRepository.save(member);

    response.setContentType("text/html");
    response.setCharacterEncoding("utf-8");
    PrintWriter w = response.getWriter();
    w.write("<html>\n" +
            "<head>\n" +
            " <meta charset=\"UTF-8\">\n" + "</head>\n" +
            "<body>\n" +
            "성공\n" +
            "<ul>\n" +
            " <li>id="+member.getId()+"</li>\n" +
            " <li>username="+member.getUsername()+"</li>\n" +
            " <li>age="+member.getAge()+"</li>\n" + "</ul>\n" +
            "<a href=\"/index.html\">메인</a>\n" + "</body>\n" +
            "</html>");
    ``` 
- `자바 코드에 HTML만드는 코드가 섞여있어서 매우 복잡하고 비효율적이다. 자바 코드로 HTML을 만드는 것보다 HTML 문서에 동적으로 변경해야 하는 부분만 자바 코드를 넣는게 더 편리할 것이다.` => JSP 등장
- 이게 바로 템플릿 엔진이 나온 이유다. 템플릿 엔진을 사용하면 HTML 문서에서 필요한 곳만 코드를 적용해 동적으로 변경할 수 있다. 
- 템플릿 엔진에는 JSP, Thymeleeaf, Freemarker, Velocity 등이 있다.

# JSP로 회원 관리 웹 애플리케이션 만들기
- `<%@ page contentType="text/html;charset=UTF-8" language="java" %>` 첫 줄은 JSP문서라는 뜻이다. JSP 문서는 이렇게 시작해야 한다.
- 회원 등록 폼 JSP를 보면 첫 줄을 제외하고는 완전히 HTML와 똑같다. `JSP는 서버 내부에서 서블릿으로 변환`되는데, 우리가 만들었던 MemberFormServlet과 거의 비슷한 모습으로 변환된다.
- `<% ~ %>` 태그 안에 자바 코드를 입력할 수 있다. 
  + `<%= ~ %>` 자바 코드를 출력할 수 있다.
- 회원 저장 JSP를 보면, 회원 저장 서블릿 코드와 같다. 다른 점이 있다면, HTML을 중심으로 하고, 자바 코드를 부분부분 입력해주었다. 
## 서블릿과 JSP의 한계 
- 서블릿으로 개발할 때는 뷰(View)화면을 위한 HTML을 만드는 작업이 자바 코드에 섞여서 지저분하고 복잡했다. JSP를 사용한 덕분에 뷰를 생성하는 HTML 작업을 깔끔하게 가져가고, 중간중간 동적으로 변경이 필요한 부분에만 자바 코드를 적용했다. 
- 하지만 코드의 상위 절반은 회원을 저장하기 위한 비즈니스 로직이고, 나머지 하위 절반만 결과를 HTML로 보여주기 위한 뷰 영역이다. 
- `JAVA 코드, 데이터를 조회하는 리포지토리 등등 다양한 코드가 모두 JSP에 노출되어 있다. JSP가 너무 많은 역할을 한다.`  

# MVC 패턴 
## 너무 많은 역할 
- `하나의 서블릿이나 JSP만으로 비즈니스 로직과 뷰 렌더링까지 모두 처리하게 되면, 너무 많은 역할을 하게되고, 결과적으로 유지보수가 어려워진다.` 
- 비즈니스 로직을 호출하는 부분에 변경이 발생해도 해당 코드를 손대야 하고, UI를 변경할 일이 있어도 비즈니스 로직이 함께 있는 해당 파일을 수정해야 한다.
## 기능 특화 
- 특히 JSP 같은 뷰 템플릿은 화면을 렌더링 하는데 최적화 되어 있기 때문에 이 부분의 업무만 담당하는 것이 가장 효과적이다.
## Model View Controller 
- 컨트롤러: HTTP 요청을 받아서 파라미터를 검증하고, 비즈니스 로직을 실행한다. 그리고 뷰에 전달할 결과 데이터를 조회해서 모델에 담는다.  
- 모델: 뷰에 출력할 데이터를 담아둔다. 뷰가 필요한 데이터를 모두 모델에 담아서 전달해주는 덕분에 뷰는 비즈니스 로직이나 데이터 접근을 몰라도 되고, 화면을 렌더링 하는 일에 집중할 수 있다. 
- 뷰: 모델에 담겨있는 데이터를 사용해서 화면을 그리는 일에 집중한다. 여기서는 HTML을 생성하는 부분을 말한다. 

- ![MVC 패턴 이전](./images/noPattern.png)
- ![MVC 1](./images/MVC1.png)
- ![MVC 2](./images/MVC2.png)

## MVC 패턴 적용
- Model은 HttpServletRequest 객체를 사용한다. request는 내부에 데이터 저장소를 가지고 있는데, request.setAttribute(), reuqest.getAttribute()를 사용하면 데이터를 보관, 조회할 수 있다. 
- `dispatcher.forward()`로 다른 서블릿이나 JSP로 이동할 수 있다. 서버 내부에서 다시 호출이 발생한다. 
- `/WEB-INF` 안에 JSP가 있으면 외부에서 직접 JSP를 호출할 수 없다. 항상 컨트롤러를 통해서 호출해야한다. 
  + localhost:8080/jsp/members.jsp. 가능  
  + localhost:8080/WEB-INF/views/members.jsp. 불가능 
- `redirect` vs `forward` 
  + redirect
    - 리다이렉트는 실제 웹 브라우저에 응답이 나갔다가, 클라이언트가 redirect 경로로 다시 요청하는 것. 따라서 클라이언트가 인지할 수 있고, URL 경로도 변경된다.
    - 클라이언트 -> 서버 -> 클라이언트가 리다이렉트 호출 -> 서버   
  + forward
    - 포워드는 서버 내부에서 일어나는 호출이기 때문에 클라이언트가 전혀 인지하지 못한다.
    - 클라이언트 -> 서버 -> 서버가 포워트 호출 
- MVC 덕분에 컨트롤러 로직과 뷰 로직을 확실하게 분리할 수 있다. 이후 화면 수정이 발생하면 뷰 로직만 변경하면 된다. 
  + 뷰
    ```
    <ul>
        <li>id=${member.id}</li>
        <li>username=${member.username}</li>
        <li>age=${member.age}</li>
    </ul>
    ```
  + ```
    @Override
    protected void service(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        //servlet과 동일한 로
        String username = request.getParameter("username");
        int age = Integer.parseInt(request.getParameter("age"));

        Member member = new Member(username, age);
        memberRepository.save(member);

        //Model에 데이터를 보관한다.
        request.setAttribute("member", member);

        String viewPath = "/WEB-INF/views/save-result.jsp";
        RequestDispatcher dispatcher = request.getRequestDispatcher(viewPath);
        dispatcher.forward(request, response);
    }
    ```

# MVC 패턴 한계 
- MVC 패턴을 적용한 덕분에 컨트롤러의 역할과 뷰를 렌더링 하는 역할을 명확하게 구분할 수 있다. 하지만 중복, 불필요한 코드가 많이 보인다. 
## 포워드 중복
- ```
  RequestDispatcher dispatcher = request.getRequestDispatcher(viewPath);
  dispatcher.forward(request, response);
  ```
## viewPath 중복
- ```
  String viewPath = "/WEB-INF/views/save-result.jsp";
  ``` 
- prefix: /WEB-INF/view/, suffix: .jsp 
- 만약 jsp가 아닌 다른 템플릿 엔진으로 변경한다면 전체 코드를 다 변경해야한다. 
## 공통 처리가 어렵다.   
- 기능이 복잡해질 수 록 컨트롤러에서 공통으로 처리해야 하는 부분이 점점 더 많이 증가할 것이다. 단순히 공통 기능을 메서드로 뽑으면 될 것 같지만, 결과적으로 해당 메서드를 항상 호출해야 하고, 실수로 호출하지 않으면 문제가 될 것이다. 그리고 호출하는 것 자체도 중복이다.
## 공통 처리가 어려우므로 프론트 컨트롤러 패턴을 도입
- 프론트 컨트롤러 패턴을 도입하여 컨트롤러 호출 전에 공통 기능을 처리하면 중복이 사라진다.  