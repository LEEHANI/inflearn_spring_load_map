# 4. 검증 - Validation 

# BindingResult1
- 스프링이 제공하는 검증 오류 처리. BindingResult
- HTTP 요청이 정상인지 검증할 때 사용된다.  
- BindingResult를 사용하지 않으면 typeMismatch 오류가 발생했을 때, 컨트롤러가 호출되지 않고 400 오류 페이지를 띄워버린다.
- BindingResult bindingResult 파라미터의 위치는 검증할 대상 @ModelAttribute Item item 다음에 바로 와야 한다.
  + ```java 
    public String addItemV1(@ModelAttribute Item item, BindingResult bindingResult RedirectAttributes redirectAttributes) {}
    ```

## FieldError
- 필드에 오류가 있으면 `FieldError` 객체를 생성해서 `bindingResult` 에 담아두면 된다.
- `public FieldError(String objectName, String field, String defaultMessage) {}`
  + bindingResult.addError(new FieldError("item", "itemName", "상품 이름은 필수입니다."));
  + objectName : @ModelAttribute 이름
  + field : 오류가 발생한 필드 이름
  + defaultMessage : 오류 기본 메시지

## ObjectError
- 특정 필드를 넘어서는 오류가 있으면 `ObjectError` 객체를 생성해서 bindingResult 에 담아두면 된다.
- public ObjectError(String objectName, String defaultMessage) {}
  + objectName : @ModelAttribute 의 이름
  + defaultMessage : 오류 기본 메시지

## 타임리프 스프링 검증 오류 통합 기능 
- 타임리프는 `#fields`로 BindingResult가 제공하는 검증 오류에 접근할 수 있다. 
- `th:errors`: 해당 필드에 오류가 있는 경우 태그를 출력. th:if의 편의 버전 
  + `<div class="field-error" th:errors="*{price}">가격 오류</div>`
- `th:errorclass`: th:field에서 지정한 필드에 오류가 있으면 class 정보를 추가함 
  + ```html 
    <input type="text" id="price" th:field="*{price}" th:errorclass="field-error" class="form-control" placeholder="가격을 입력하세요">
    <div class="field-error" th:errors="*{price}">
      가격 오류
    </div>
    ```

### 글로벌 오류 처리 
- th:if="${#fields.hasGlobalErrors()}"
- ```
  <div th:if="${#fields.hasGlobalErrors()}">
    <p class="field-error" th:each="err : ${#fields.globalErrors()}" th:text="${err}">글로벌 오류 메시지</p>
  </div>
  ```
### 필드 오류 처리 
- ```
  <input type="text" id="itemName" th:field="*{itemName}" th:errorclass="field-error" class="form-control" placeholder="이름을 입력하세요">
  <div class="field-error" th:errors="*{itemName}">
    상품명 오류
  </div>
  ```
  
# BindingResult2
## `@ModelAttribute`에 데이터 바인딩 시 타입 오류 등이 발생하면?
- BindingResult 가 없으면, `400 오류`가 발생하면서 컨트롤러가 호출되지 않고, `오류 페이지`로 이동한다.
- BindingResult 가 있으면, `오류 정보( FieldError )를 BindingResult 에 담아서 컨트롤러를 정상 호출`한다.

## BindingResult에 검증 오류를 적용하는 3가지 방법 
1. @ModelAttribute 객체에 타입 오류 등으로 바인딩에 실패하면 스프링이 FieldError 생성해서 BindingResult에 넣어준다.
2. 개발자가 직접 넣어준다
  + bindingResult.addError(new FieldError("item", "itemName", "상품 이름은 필수입니다.")
3. Validator 사용 

## BindingResult와 Errors 
- BindingResult는 Errors를 상속받는 인터페이스이다. 
- 구현체는 BeanPropertyBindingResult이다. 
- `Errors를 사용해도 되지만 추가적이 기능을 제공하는 BindingResult를 주로 사용한다.` 

## FieldError 생성자 
- ```
  public FieldError(String objectName, String field, String defaultMessage);
  
  public FieldError(String objectName, String field, @Nullable Object rejectedValue, boolean bindingFailure, @Nullable String[] codes, @Nullable Object[] arguments, @Nullable String defaultMessage)
  ```
  + `objectName` : 오류가 발생한 객체 이름
  + `field` : 오류 필드
  + `rejectedValue : 사용자가 입력한 값(거절된 값)`
  + `bindingFailure` : 타입 오류 같은 바인딩 실패인지, 검증 실패인지 구분 값 
  + `codes : 메시지 코드` 
  + `arguments : 메시지에서 사용하는 인자`
  + `defaultMessage` : 기본 오류 메시지

## 오류 발생시 사용자 입력 값 유지 
- 오류 발생시 입력한 값을 유지하려면, FieldError의 `rejectedValue` 필드가 있는 생성자를 사용하면 된다.
- new FieldError("item", "price", item.getPrice(), false, null, null, "가격은 1,000 ~ 1,000,000 까지 허용합니다.")

# 오류 코드와 메시지 처리 
- 기존에는 직접 메시지를 줬지만, 코드로 관리할 수 있다. FieldError , ObjectError 의 생성자는 `errorCode`, `arguments` 를 사용하면 코드로 관리할 수 있다. 
  + 기존: `new FieldError("item", "itemName", "상품 이름은 필수입니다.")`
  + 코드로 관리: `new FieldError("item", "price", item.getPrice(), false, new String[] {"range.item.price"}, new Object[]{1000, 1000000}`
    - Object[]{1000, 1000000} 를 사용해서 코드의 {0} , {1} 로 치환할 값을 전달한다.
- errors.properties 파일을 새로 만들고 메시지 설정을 추가하자. 
  + spring.messages.basename=messages,errors
- errors_en.properties로 국제화도 적용 가능하다. 


## FieldError, ObjectError보다 간결한 bindingResult.rejectValue
- `FieldError, ObjectError를 직접 생성하지 않고, BindingResult가 제공하는 rejectValue(), reject()를 사용하면 더 깔끔하게 사용할 수 있다.`
- bindingResult.rejectValue("price", "range", new Object[]{1000, 1000000}, null);

## 축약된 오류 코드 
- FieldError() 를 직접 다룰 때는 오류 코드를 range.item.price 와 같이 모두 입력했다. 
- 그런데 rejectValue() 를 사용하고 부터는 오류 코드를 range 로 간단하게 입력했다. 
- `MessageCodesResolver`가 이를 가능하게 해준다. 

# MessageCodesResolver
- MessageCodesResolver는 더 정확한 코드를 우선으로 사용한다. 
- ```
  #Level1
  required.item.itemName: 상품 이름은 필수 입니다. 
  
  #Level2
  required: 필수 값 입니다.
  ```
- MessageCodesResolver 인터페이스이고 DefaultMessageCodesResolver 는 기본 구현체이다.
- rejectValue() , reject() 는 내부에서 MessageCodesResolver 를 사용한다. 여기에서 메시지 코드들을 생성한다.
- FieldError , ObjectError 의 생성자를 보면, 오류 코드를 하나가 아니라 new String[]으로 여러 오류 코드를 가질 수 있다. MessageCodesResolver 를 통해서 생성된 순서대로 오류 코드를 보관한다.

## FieldError rejectValue("itemName", "required")
- 다음 4가지 오류 코드를 자동으로 생성
- ```
  1. required.item.itemName 
  2. required.itemName 
  3. required.java.lang.String 
  4. required
  ```

## ObjectError reject("totalPriceMin") 
- 다음 2가지 오류 코드를 자동으로 생성
- totalPriceMin.item 
- totalPriceMin

## 핵심은 구체적인 것에서! 덜 구체적인 것으로!
- MessageCodesResolver 는 required.item.itemName 처럼 구체적인 것을 먼저 만들어주고, required 처럼 덜 구체적인 것을 가장 나중에 만든다.
- `그렇다면 오류 메시지는 범용성 있는 requried 같은 메시지로 끝내고, 정말 중요한 메시지는 꼭 필요할 때 구체적으로 적어서 사용하는 방식이 더 효과적이다.` 
- 이렇게 하면 만약에 크게 중요하지 않은 오류 메시지는 기존에 정의된 것을 그냥 재활용 하면 된다!
- 메시지 코드 전략 강점을 활용하면, 스프링이 넣어주는 메시지 코드도 컨트롤할 수 있다.
- 스프링은 타입 오류가 발생하면 typeMismatch라는 오류 코드를 사용한다. 
  + ```
    Failed to convert property value of type java.lang.String to required type
    java.lang.Integer for property price; nested exception is
    java.lang.NumberFormatException: For input string: "A"
    ```
- error.properties에 다음 내용을 추가하면 메시지를 바꿀 수 있다. 
  + ```
    #추가
    typeMismatch.java.lang.Integer=숫자를 입력해주세요. 
    typeMismatch=타입 오류입니다.
    ```

# Validator
- 컨트롤러에 있는 검증 로직을 별도의 클래스로 분리하자. 
- 스프링은 검증을 체계적으로 제공하기 위해 다음 인터페이스를 제공한다.
- ```java
  public interface Validator {
    boolean supports(Class<?> clazz);
    void validate(Object target, Errors errors);
  }
  ```
- ```java
  @Component
  public class ItemValidator implements Validator {
    @Override
    public boolean supports(Class<?> clazz) {
      return Item.class.isAssignableFrom(clazz); 
    }
  
    @Override
    public void validate(Object target, Errors errors) {...} 
    
    }
  ```
## validator 직접 호출하기 
- ItemValidator를 스프링 빈으로 주입받아 직접 호출하기
- ```java
  private final ItemValidator itemValidator;

  @PostMapping()
  public String addItemV5(@ModelAttribute Item item, BindingResult bindingResult) {
    itemValidator.validate(item, bindResult);
    ...
  }

  ```

## WebDataBinder를 통해서 사용하기 
- `@InitBinder`에 추가하면 `@Validated`가 있는 컨트롤러 호출시마다 검증 로직이 실행된다. 
  + ```java
    @InitBinder
    public void init(WebDataBinder dataBinder) {
        dataBinder.addValidators(itemValidator);
    }
    ```
  + ```java
    public String addItemV6(@Validated @ModelAttribute Item item, BindingResult bindingResult, RedirectAttributes redirectAttributes, Model model) { }
    ```
- 근데 검증기를 여러개 등록한다면, 그 중에 어떤 검증기가 실행되어야하는지 구분이 필요하다. 그때 supports()가 사용된다.
- supports(Item.class) 호출되고, 그 결과가 true이므로 ItemValidator.validate()가 호출된다. 

## 참고 
- @Validate, @Valid 둘 다 사용가능하다. 
  + @Validate: 스프링 전용 검증 애노테이션
  + @Valid: 자바 표준 검증 애노테이션 
- @Valid를 사용하려면 의존성이 추가로 필요하다. 
  + implementation 'org.springframework.boot:spring-boot-starter-validation'


# 5. 검증2 - Bean Validation
- 검증 기능을 위에 처럼 매번 코드로 작성하는 건 번거로운 일이다. 특히 필드에 대한 검증 로직은 대부분 빈 값인지, 특정 사이즈를 넘는지와 같은 것을 검증하는게 빈번하다. 
- 이런 검증 로직을 모든 프로젝트에 적용할 수 있게 공통화하고, 표준화 한 것이 바로 Bean Validation이다. 
```
@Data
public class Item {
    
    private Long id;
    
    @NotBlank
    private String itemName;
    
    @NotNull
    @Range(min = 1000, max = 1000000)
    private Integer price;
    
    @NotNull
    @Max(9999)
    private Integer quantity;
}
```

## Bean Validation이란?
- `Bean Validation`은 특정한 구현체가 아니라 Bean Validation 2.0(JSR-380)이라는 `기술 표준`이다. 
- 쉽게 이야기해서 검증 애노테이션과 여러 인터페이스의 모음이다. 마치 JPA가 표준 기술이고 그 구현체로 하이버네이트가 있는 것과 같다
- 이름이 하이버네이트가 붙어서 그렇지 ORM과는 관련이 없다.

# Bean Validation 시작 
## 의존관계 추가 
- `implementation 'org.springframework.boot:spring-boot-starter-validation'`
## 검증 애노테이션 
- `@NotBlank` : 빈값 + 공백만 있는 경우를 허용하지 않는다.
- `@NotNull` : null 을 허용하지 않는다.
- `@Range(min = 1000, max = 1000000)` : 범위 안의 값이어야 한다. 
- `@Max(9999)` : 최대 9999까지만 허용한다.
- javax.validation은 특정 구현에 관계없이 제공된느 표준 인터페이스
- org.hibernate.validator로 시작하면 하이버네이트 validator 구현체를 사용할 때만 제공되는 기능. 대부분 실무에서 사용

## 스프링 MVC는 어떻게 Bean Validator를 사용?
- 스프링 부트가 spring-boot-starter-validation 라이브러리를 넣으면 자동으로 Bean Validator를 인지하고 스프링에 통합한다.
- 스프링 부트는 자동으로 LocalValidatorFactoryBean을 글로벌 Validator로 등록한다.
- `글로벌 Validator가 적용`되어 있기 때문에, `@Valid`, `@Validated` 만 적용하면 된다.
- `검증 오류가 발생하면, FieldError , ObjectError 를 생성해서 BindingResult` 에 담아준다.
- 직접 글로벌 Validator를 직접 등록하면 스프링 부트는 Bean Validator를 글로벌 Validator 로 등록하지 않으므로 조심해야함. 

## Valid ? Validated ?
- 검증시 @Validated @Valid 둘다 사용가능하다.
- @Validated 는 스프링 전용 검증 애노테이션이고 
- @Valid 는 자바 표준 검증 애노테이션. 
- 둘중 아무거나 사용해도 동일하게 작동하지만, `@Validated 는 내부에 groups 라는 기능을 포함하고 있다`

## 검증 순서 
1. @ModelAttribute 각각의 필드에 타입 변환 시도 
   1. 성공하면 다음으로
   2. 실패하면 typeMismatch 로 FieldError 추가 
2. Validator 적용
- `바인딩에 성공한 필드만 Bean Validation 적용` 
- `@ModelAttribute` -> `각각의 필드 타입 변환시도` -> `변환에 성공한 필드만 BeanValidation 적용`

# Bean Validation 에러 코드 
- `typeMismatch`와 유사하게 `NotBlank`도 오류 코드를 기반으로 `MessageCodesResolver` 를 통해 다양한 메시지 코드가 순서대로 생성된다.
- @NotBlank
  + NotBlank.item.itemName 
  + NotBlank.itemName 
  + NotBlank.java.lang.String 
  + NotBlank

## BeanValidation 메시지 찾는 순서
1. 생성된 메시지 코드 순서대로 `messageSource` 에서 메시지 찾기
2. `애노테이션의 message 속성` 사용 -> @NotBlank(message = "공백! {0}") 
3. `라이브러리가 제공하는 기본 값` -> 사용 공백일 수 없습니다.

# Bean Validation - 오브젝트 오류. @ScriptAssert. 권장X 
- FieldError는 @NotBlank, @Range로 해결했다. 
- `ObjectError`오류는 @ScriptAssert()를 사용하면 된다. 
- ```
  @Data
  @ScriptAssert(lang = "javascript", script = "_this.price * _this.quantity >= 10000")
  public class Item {
    //...
  }
  ```
- 실무에서는 검증 기능이 해당 객체의 범위를 넘어서는 경우들도 종종 등장하는데, 그런 경우 대응이 어렵다.
- `오브젝트 오류 관련 부분만 직접 자바 코드로 작성하는 것을 권장한다.`
- ```
  if (item.getPrice() != null && item.getQuantity() != null) {
    int resultPrice = item.getPrice() * item.getQuantity();
  
    if (resultPrice < 10000) {
      bindingResult.reject("totalPriceMin", new Object[]{10000, resultPrice}, null);
    }
  }
  ```

# Bean Validation 한계
- 등록할 때 Item 모델 객체 사용. 수정할 때도 Item 모델 객체 사용. 이때 등록과 수정시에 validation 요구 사항이 다르다면?
- `동일한 모델 객체에서 조건을 다르게 적용할 수 없다.`

## 해결 방법
- BeanValidation의 groups 기능을 사용. 권장 X 
- `ItemSaveForm, ItemUpdateForm 같이 별도의 모델 객체를 만든다.` 

## Bean Validation - groups 
- 저장용 groups
  + ```
    public interface SaveCheck {}
    ```
- 수정용 groups
  + ```
    public interface UpdateCheck {}
    ```
- item에 적용 
  + ```
    @Data
    public class Item {

      @NotNull(groups = UpdateCheck.class)
      private Long id;

      @NotBlank(groups = {SaveCheck.class, UpdateCheck.class})
      private String itemName;

      @NotNull(groups = {SaveCheck.class, UpdateCheck.class})
      @Range(min = 1000, max = 1000000)
      private Integer price;

      @NotNull(groups = {SaveCheck.class, UpdateCheck.class})
      @Max(value = 9999, groups = {SaveCheck.class})
      private Integer quantity;
    }
    ```
- controller에 적용. `@Validated(SaveCheck.class) @ModelAttribute Item item` 
  + ```
    @PostMapping("/add")
    public String addItemV2(@Validated(SaveCheck.class) @ModelAttribute Item item, BindingResult bindingResult, RedirectAttributes redirectAttributes) {
      //...
    }
    ```
- @Valid 에는 groups를 적용할 수 있는 기능이 없다. 따라서 `groups를 사용하려면 @Validated 를 사용해야 한다.`

# Bean Validation - HTTP 메시지 컨버터 
- `@Valid, @Validated 는 HttpMessageConverter (@RequestBody)에도 적용할 수 있다.` 

## API의 경우 3가지 경우가 나옴 
- 성공 요청: 성공
- 실패 요청: JSON을 객체로 생성하는 것 자체가 실패함
  + 객체를 만들지 못하기 때문에 컨트롤러 자체가 호출되지 않고 그 전에 예외가 발생. 물론 validator도 실행되지 않음 
  + `typeMismatch 발생 시 @ModelAttribute와 달리 실패했을 때, BindingResult에 담기지 않고 바로 400예외를 리턴한다.`
- 검증 오류 요청: JSON을 객체로 생성하는 것은 성공했으나 검증에서 실패 

## @ModelAttribute vs @RequestBody
- `@ModelAttribute는 필드 단위로 정교하게 바인딩이 적용된다.` 특정 필드가 바인딩 되지 않아도 나머지 필드는 정상 바인딩 되고, Validator를 사용한 검증도 적용할 수 있다.
- `@RequestBody 는 HttpMessageConverter 단계에서 JSON 데이터를 객체로 변경하지 못하면 이후 단계 자체가 진행되지 않고 예외가 발생한다. 컨트롤러도 호출되지 않고, Validator도 적용할 수 없다.`

