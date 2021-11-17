 # 메시지, 국제화 소개 
 
# 메시지
- HTML 파일에 메시지가 하드코딩 되어있다면, 수정사항이 발생했을 때 수십개의 파일을 모두 고쳐야한다.
- 이런 다양한 메시지를 한 곳에서 관리하도록 하는 기능을 메시지 기능이라 한다. 
- messages.properties에 메시지를 만들어놓고 <label for="itemName" th:text="#{item.itemName}" /> 이런 식으로 불러 쓸 수 있다. 

# 국제화 
- messages.properties를 각 나라별로 관리하면 서비스를 국제화 할 수 있다. 
- messages_en.properties, messages_ko.properties로 나라별로 구분할 수 있는데, `HTTP accept-language` 헤더 값으로 구분하거나 쿠키 등을 사용해서 처리할 수 있다. 

## 스프링 메시지 소스 설정 
- 메시지 관리 기능을 사용하려면 스프링이 제공하는 MessageSource 를 스프링 빈으로 등록하면 된다. 
- MessageSource는 인터페이스 이므로 구현체인 ResourceBundleMessageSource를 빈으로 등록하면 된다. 
- ```
  @Bean
  public MessageSource messageSource() {
      ResourceBundleMessageSource messageSource = new ResourceBundleMessageSource();
      messageSource.setBasenames("messages", "errors"); 
      messageSource.setDefaultEncoding("utf-8"); 
      return messageSource;
  }
  ```
- messages를 등록하면 `/resources/messages.properties`에 있는 파일을 읽어서 사용한다. 

## 스프링 부트 메시지 소스 설정
- `스프링 부트는 MessageSource를 스프링 빈으로 자동 등록해준다.`
- `application.properties. spring.messages.basename=messages,config.i18n.messages`
- MessageSource 를 스프링 빈으로 등록하지 않고, 스프링 부트와 관련된 별도의 설정을 하지 않으면 messages 라는 이름으로 기본 등록된다. 
- 따라서 `messages_en.properties`, `messages_ko.properties`, `messages.properties` 파일만 등록하면 자동으로 인식된다.

## 메시지 소스 사용 
- ```properties
  //messages.properties
  hello=안녕 
  hello.name=안녕 {0}
  ```
- ```java
  @Autowired
  MessageSource ms;
  
  @Test
  void helloMessage() {
    String result = ms.getMessage("hello", null, null); 
    assertThat(result).isEqualTo("안녕");
  }
  ```
- ms.getMessage("hello", null, null)
  + code: hello
  + args: null
  + locale: null
- locale 정보가 없으면 기본 이름 메시지 파일인 messages.properties 파일에서 데이터를 조회한다.  
- 메시지 키가 없는 경우 NoSuchMessageException이 발생 
- 메시지가 없어도 기본 메시지를 사용할 수 있다.  
  + ms.getMessage("hello", null, "기본 메시지", null); 
- {0} 부분은 매개변수를 전달해서 치환할 수 있다. 
  + ms.getMessage("hello.name", new Object[]{"Spring"}, null); 

## 타임리프 메시지 적용 
- 타임리프의 메시지 표현식 `#{...}`를 사용하면 스프링의 메시지를 편리하게 조회할 수 있다. 
- `<label for="itemName" th:text="#{item.itemName}" />`
- 참고로 파라미터는 다음과 같이 사용할 수 있다.
  + hello.name=안녕 {0}
  + `<p th:text="#{hello.name(${item.itemName})}" />`
    
## 스프링의 국제화 메시지 선택 
- `MessageSource는 Locale의 정보를 알아야 언어를 선택할 수 있는데, 스프링은 언어 선택시 기본으로 Accept-Language 헤더의 값을 사용한다.` 
- Locale 선택 방식을 변경할 수 있도록 LocaleResolver라는 인터페이스를 제공하는데, 스프링 부트는 기본으로 Accept-Language를 활용하는 `AcceptHeaderLoaleResolver`를 사용 
- 쿠키나 세션 기반으로 변경하고 싶으면 LocaleResolver의 구현체를 변경하면 된다. 