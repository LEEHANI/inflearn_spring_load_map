# 10. 스프링 타입 컨버터  


# 스프링 타입 컨버터 소개 
- HttpServletRequest에서 파라미터를 직접 꺼내면 String 타입이기 때문에 형 변환을 해주는 과정이 필요하다. 
- ```
  String data = request.getParameter("data");
  Integer intValue = Integer.valueOf(data);
  ```
- 이 과정은 매우 번거롭다. @RequestParam 을 사용하면, 스프링이 중간에서 타입을 변환해주므로 쉽게 숫자형으로 받을 수 있다. 

## 스프링 타입 변환 적용 예 
- @RequestParam, @modelAttribute, @PathVariable 
- @Value 등으로 YML 정보 읽기
- 뷰를 렌더링할 때 

## 스프링과 타입 변환 
- 만약 새로운 타입을 만들어서 변환하고 싶으면 어떻게 하면 될까?
- ```java
  package org.springframework.core.convert.converter;
    public interface Converter<S, T> {
      T convert(S source);
  }
  ```
- 추가적인 타입 변환이 필요하면 이 컨버터 인터페이스를 구현해서 등록하면 된다. 
- 모든 타입에 적용할 수 있는데, S 타입을 T로 변환하는 작업을 convert 메서드에서 구현하면 된다. 

# 타입 컨버터 - Converter
- StringToIpPortConverter. String -> IpPort 
- ```
  import org.springframework.core.convert.converter.Converter;

  @Slf4j
  public class StringToIpPortConverter implements Converter<String, IpPort> {

    @Override
    public IpPort convert(String source) {
        log.info("convert source={}", source);
        String[] split = source.split(":");
        String ip = split[0];
        int port = Integer.parseInt(split[1]);
        return new IpPort(ip, port);
    }
  }  
  ```
- IpPortToStringConverter. IpPort -> String
- ```java
  @Slf4j
  public class IpPortToStringConverter implements Converter<IpPort, String> {

    @Override
    public String convert(IpPort source) {
        log.info("convert source={}", source);
        return source.getIp() + ":" + source.getPort();
    }
  }
  ```
- 테스트 코드 
- ```
  @Test
  void stringToIpPort() {
    IpPortToStringConverter converter = new IpPortToStringConverter();
    String result = converter.convert(new IpPort("127.0.0.1", 8080));
    assertThat(result).isEqualTo("127.0.0.1:8080");
  }

  @Test
  void ipPortToString() {
    StringToIpPortConverter converter = new StringToIpPortConverter();
    IpPort result = converter.convert("127.0.0.1:8080");
    assertThat(result).isEqualTo(new IpPort("127.0.0.1", 8080));
  }
  ```

## 참고 
- 스프링은 문자, 숫자, 불린, Enum 등 일반적인 타입에 대해 대부분의 컨버터를 기본으로 제공한다.
- `Converter` 기본 타입 컨버터
- `ConverterFactory` 전체 클래스 계층 구조가 필요할 때 
- `GenericConverter` 정교한 구현, 대상 필드의 애노테이션 정보 사용 가능 
- `ConditionalGenericConverter` 특정 조건이 참인 경우에만 실행

# 컨버전 서비스 - ConversionService 
- 컨버터를 일일이 찾아서 적용하는 건 불편하다. 
- 스프링은 개별 컨버터를 모아두고 그것들을 묶어서 편리하게 사용할 수 있는 기능인 컨버전 서비스를 제공한다.
- ```java
  public interface ConversionService {
    boolean canConvert(@Nullable Class<?> sourceType, Class<?> targetType);
    boolean canConvert(@Nullable TypeDescriptor sourceType, TypeDescriptor targetType);
  
    <T> T convert(@Nullable Object source, Class<T> targetType);
    Object convert(@Nullable Object source, @Nullable TypeDescriptor sourceType, TypeDescriptor targetType);
  }
  ```
- 컨버전 서비스는 `컨버팅이 가능한지 확인하는 기능`과 `컨버팅 기능`을 제공한다.
- 컨버전 서비스 테스트 코드 
- ```
  @Test
  void conversionService() {
        //등록
        DefaultConversionService conversionService = new DefaultConversionService();
        conversionService.addConverter(new StringToIntegerConverter());
        conversionService.addConverter(new IntegerToStringConverter());
        conversionService.addConverter(new StringToIpPortConverter());
        conversionService.addConverter(new IpPortToStringConverter());

        //사용
        Assertions.assertThat(conversionService.convert("10", Integer.class)).isEqualTo(10);
        Assertions.assertThat(conversionService.convert(10, String.class)).isEqualTo("10");
        Assertions.assertThat(conversionService.convert("127.0.0.1:8080", IpPort.class)).isEqualTo(new IpPort("127.0.0.1", 8080));
        Assertions.assertThat(conversionService.convert(new IpPort("127.0.0.1", 8080), String.class)).isEqualTo("127.0.0.1:8080");
  }
  ```
- DefaultConversionService 는 ConversionService 인터페이스를 구현했는데, 추가로 컨버터를 등록하는 기능도 제공한다. 
- 
## 등록과 사용 분리
- 컨버터를 등록할 때는 StringToIntegerConverter 같이 타입 컨버터를 명확하게 알아야 한다.
- 반면에, 컨버터를 사용하는 입장에서는 어떤 타입 컨버터인지 몰라도 된다. 타입 컨버터들은 모두 컨버전 서비스 내부에 숨어서 제공이 된다. 
- 따라서 컨버터 사용을 원하는 사용자는 `컨버전 서비스 인터페이스`에만 의존하면된다.
- 물론 컨버전 서비스를 등록하는 부분과 사용하는 부분을 분리하고 의존관계 주입을 사용해야 함. 

## 인터페이스 분리 원칙 - ISP(Interface Segregation Principal)
- 클라이언트가 자신이 이용하지 않는 메서드에 의존하지 않아야 한다. 
- DefaultConversionService는 다음 두 인터페이스를 구현함 
  + ConversionService: 컨버터 사용에 초점 
  + ConverterRegistry: 컨버터 등록에 초점 
- 이렇게 인터페이스를 분리하면 컨버터를 사용하는 클라이언트와 컨버터를 등록하고 관리하는 클라이언트의 관심사를 명확하게 분리할 수 있다. 
- 특히 컨버터를 사용하는 클라이언트는 ConversionService 만 의존하면 되므로, 컨버터를 어떻게 등록하고 관리하는지는 전혀 몰라도 된다. 
- 결과적으로 컨버터를 사용하는 클라이언트는 꼭 필요한 메서드만 알게된다. 이렇게 인터페이스를 분리하는 것을 ISP 라 한다.

# 스프링에 컨버터 적용하기 
- ```java
  @Configuration
  public class WebConfig implements WebMvcConfigurer {

    @Override
    public void addFormatters(FormatterRegistry registry) {
      registry.addConverter(new StringToIntegerConverter());
      registry.addConverter(new IntegerToStringConverter());
      registry.addConverter(new StringToIpPortConverter());
      registry.addConverter(new IpPortToStringConverter());

      registry.addFormatter(new MyNumberFormatter());
    }
  }
  ```
- WebMvcConfigurer가 제공하는 addFormatter()에 등록해주면 스프링은 내부에서 `ConversionService`에 컨버터를 추가해준다. 
- 컨버터가 잘 동작하는지 테스트해보자. 

## 테스트
- ```
  @GetMapping("/ip-port")
  public String ipPort(@RequestParam IpPort ipPort) {
    System.out.println("ipPort = " + ipPort.getPort());
    System.out.println("ipPort = " + ipPort.getIp());
    return "ok";
  }
  ```
- http://localhost:8080/ip-port?ipPort=127.0.0.1:8080로 테스트해보면 `ipPort=127.0.0.1:8080` 쿼리 스트링이 IpPort 객체 타입으로 잘 변환 된 것을 확인할 수 있다. 
- RequestParamMethodArgumentResolver에서 ConversionService를 사용해서 타입을 변환한다. 

## 뷰 템플릿에 컨버터 적용하기 
- 타임리프는 `${{...}}`를 사용하면 자동으로 컨버전 서비스를 사용해서 변환된 결과를 출력해준다. 
- ```
  <ul>
      <li>${number}: <span th:text="${number}" ></span></li>
      <li>${{number}}: <span th:text="${{number}}" ></span></li>
      <li>${ipPort}: <span th:text="${ipPort}" ></span></li>
      <li>${{ipPort}}: <span th:text="${{ipPort}}" ></span></li>
  </ul>
  ```
- ```
  • ${number}: 10000
  • ${{number}}: 10000
  • ${ipPort}: hello.typeconverter.type.IpPort@59cb0946
  • ${{ipPort}}: 127.0.0.1:8080
  ```
- `${{ipPort}}`는 컨버터를 적용하게 되면 `IpPortToStringConverter`가 적용된다. 그 결과 `127.0.0.1:8080`가 출력된다.

# 포맷터 - Formatter
- `Converter`는 입력과 출력 타입에 제한이 없는 `범용 타입 변환` 기능을 제공한다. 
- `Formatter`는 특정한 포멧에 맞추어 `문자로 출력`하거나 또는 그 반대의 역할을 하는 것에 특화된 기능이다. `컨버터의 특별한 버전.`
  - 문자에 특화.(객체 -> 문자, 문자 -> 객체) + 현지화(Locale)
- 숫자 1000 -> "1,000" 혹은 "1,000" -> 숫자 1000과 같은 상황에 쓰임.

## Formatter 만들기 
- Formatter interface
- ```java
  public interface Printer<T> {
    String print(T object, Locale locale);
  }
  
  public interface Parser<T> {
    T parse(String text, Locale locale) throws ParseException;
  }
  
  public interface Formatter<T> extends Printer<T>, Parser<T> {
  }
  ```
- 숫자 1000 -> "1,000" 해주는 포맷터를 만들어보자. 
- ```java
  @Slf4j
  public class MyNumberFormatter implements Formatter<Number> {

    @Override
    public Number parse(String text, Locale locale) throws ParseException {
        log.info("text={}, locale={}", text, locale);
        //"1,000" -> 1000
        return NumberFormat.getInstance(locale).parse(text);
    }

    @Override
    public String print(Number object, Locale locale) {
        log.info("object={}, locale={}", object, locale);
        return NumberFormat.getInstance(locale).format(object);
    }
  }
  ```
- "1,000" 처럼 중간에 쉼표를 적용하려면 자바가 제공하는 NumberFormat 객체를 이용하면 된다.   
- 테스트 코드 
- ```java
  class MyNumberFormatterTest {

    MyNumberFormatter formatter = new MyNumberFormatter();

    @Test
    void parse() throws ParseException {
        Number result = formatter.parse("1,000", Locale.KOREA);
        assertThat(result).isEqualTo(1000L);
    }

    @Test
    void print() {
        String result = formatter.print(1000, Locale.KOREA);
        assertThat(result).isEqualTo("1,000");
    }

  }
  ```

## 포맷터를 지원하는 컨버전 서비스 
- 포맷터를 지원하는 컨버전 서비스를 사용하면 내부에서 어댑터 패턴을 사용해서 Formatter가 Converter 처럼 동작하도록 지원한다. 
- `FormattingConversionService`는 포맷터를 지원하는 컨버전 서비스이다.
- DefaultFormattingConversionService 는 FormattingConversionService 에 기본적인 통화, 숫자 관련 몇가지 기본 포맷터를 추가해서 제공한다.
- ```
  @Test
  void formattingConversionService() {
    DefaultFormattingConversionService conversionService = new DefaultFormattingConversionService();
    //컨버터 등록
    conversionService.addConverter(new StringToIpPortConverter());
    conversionService.addConverter(new IpPortToStringConverter());
    //포멧터 등록
    conversionService.addFormatter(new MyNumberFormatter());

    //컨버터 사용
    IpPort ipPort = conversionService.convert("127.0.0.1:8080", IpPort.class);
    assertThat(ipPort).isEqualTo(new IpPort("127.0.0.1", 8080));
    //포멧터 사용
    assertThat(conversionService.convert(1000, String.class)).isEqualTo("1,000");
    assertThat(conversionService.convert("1,000", Long.class)).isEqualTo(1000L);
  }
  ```
- FormattingConversionService는 ConversionService 관련 기능을 상속받기 때문에 결과적으로 컨버터, 포맷터 모두 등록할 수 있다. 
- 그리고 사용할 때는 ConversionSerivce가 제공하는 convert를 사용하면 된다. 

## 포멧터 적용하기 
- ```
  @Override
  public void addFormatters(FormatterRegistry registry) {
    //        registry.addConverter(new StringToIntegerConverter());  문자->숫자, 숫자->문자 겹치므로 우선순위 때문에 주석처리 
    //        registry.addConverter(new IntegerToStringConverter());
    registry.addConverter(new StringToIpPortConverter());
    registry.addConverter(new IpPortToStringConverter());

    registry.addFormatter(new MyNumberFormatter());
  }
  ```
- 객체 -> 문자 포맷터. http://localhost:8080/converter-view 테스트해보자
- ``` 
  • ${number}: 10000
  • ${{number}}: 10,000
  ```
- 문자 -> 객체 포맷터. http://localhost:8080/hello-v2?data=10,000   
- ```
  MyNumberFormatter : text=10,000, locale=ko_KR 
  data = 10000
  ```

## 스프링이 제공하는 기본 포맷터 
- `@NumberFormat`: 숫자 관련 형식 지정 포멋터 
- `@DateTimeFormat`: 날짜 관련 현식 지정 포맷터 
- ```java
  @Data
  static class Form {
    @NumberFormat(pattern = "###,###")
    private Integer number;
  
    @DateTimeFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime localDateTime;
  }
  ```

## 주의 
- `메시지 컨버터(HttpMessageConverter)`에는 `컨버전 서비스`가 적용되지 않는다.
- HttpMessageConverter의 역할은 HTTP 메시지 바디의 내용을 객체로 변환하거나, 객체를 HTTP 메시지 바디에 입력하는 것이다. 
- JSON 결과로 만들어지는 숫자나 날짜 포맷을 변경하고 싶으면 해당 라이브러리가 제공하는 설정을 통해서 포맷을 지정해야 한다. 
- 이것은 컨버전 서비스와 전혀 관계가 없다. 
- `컨버전 서비스`는 `@RequestParam`, `@ModelAttribte`, `@PathVariable`, 뷰 템플릿 등에서 사용할 수 있다. 