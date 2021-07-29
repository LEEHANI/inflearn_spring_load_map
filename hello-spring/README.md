# spring boot
- spring-boot-starter-xx 에서 spring 의존성들을 관리해줌
- spring-boot-starter-web
  + spring-boot-starter-tomcat
  + spring-webmvc
- spring-boot-starter: 스프링 부트 + 스프링 코어 + 로깅    

## thymeleaf 템플릿엔진 동작 
- 웹 브라우저 request -> 내장 톰캣 서버 -> 스프링 컨테이너 -> controller -> viewResolver -> return html

# 스프링 웹 개발 기초 
## 정적 컨텐츠
- 실행: http://localhost:8080/hello-static.html 
- 웹 브라우저 request -> 내장 톰캣 서버 -> 스프링 컨테이너 -> controller에서 조회x -> resources/static/hello-static.html

## MVC와 템플릿 엔진 
- 실행: http://localhost:8080/hello-mvc?name=spring
- 웹 브라우저 request -> 내장 톰캣 서버 -> 스프링 컨테이너 -> HelloController hello-mvc -> viewResolver -> return html

## API 
- 실행: http://localhost:8080/hello-string?name=spring
- 웹 브라우저 request -> 내장 톰캣 서버 -> 스프링 컨테이너 -> HelloController @ResponseBody hello-api -> HttpMessageConverter -> return Json or String

# 스프링 DB 접근 기술 
## 순수 JDBC
- 직접 커넥션을 만들고 쿼리를 짜고 결과값을 반환한다. 마지막엔 사용한 자원을 꼭 종료해줘야한다. 이 과정에서 중복 코드가 많이 발생하고 코드가 굉장히 길다. 

## 스프링 JdbcTemplate
- 순수 JDBC에서 커넥션을 만들고, 자원을 종료하는 등 반복되는 부분을 template 패턴을 써서 중복 코드를 줄여준다. 하지만 SQL은 직접 작성해야한다.  

## JPA
- 기본적인 SQL을 제공해준다. 개발 생산성을 크게 높일 수 있다. 
- SQL과 데이터 중심 설계에서 객체 중심의 설계로 패러다임을 전환할 수 있다. ORM 

## Spring Data JPA
- 레파지토리 구현 클래스 없이 인터페이스만으로 개발을 할 수 있다. 
- 기본 CRUD 기능도 스프링 데이터 JPA가 제공한다. 
