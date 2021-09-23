# 4. 검증 - Validation 

# BindingResult1
- BindingResult bindingResult 파라미터의 위치는 검증할 대상 @ModelAttribute Item item 다음에 바로 와야 한다.
  + public String addItemV1(@ModelAttribute Item item, BindingResult bindingResult, RedirectAttributes redirectAttributes) {}

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
### 글로벌 오류 처리 
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
- Errors를 사용해도 되지만 추가적이 기능을 제공하는 BindingResult를 주로 사용한다.

## 오류 발생시 사용자 입력 값 유지 
- 오류 발생시 입력한 값을 유지하려면, FieldError의 rejectedValue 필드를 사용하면 된다.
- new FieldError("item", "price", item.getPrice(), false, null, null, "가격은 1,000 ~ 1,000,000 까지 허용합니다.")

# 오류 코드와 메시지 처리 
- 오류 메시지를 직접 줘도 되지만, 별도의 코드로 관리할 수 있다.
- errors.properties 파일을 새로 만들고 메시지 설정을 추가하자. 
  + spring.messages.basename=messages,errors
- errors_en.properties로 국제화도 적용 가능하다. 

## FieldError 생성자 
- public FieldError(String objectName, String field, String defaultMessage);
- public FieldError(String objectName, String field, @Nullable Object rejectedValue, boolean bindingFailure, @Nullable String[] codes, @Nullable Object[] arguments, @Nullable String defaultMessage)
  + objectName : 오류가 발생한 객체 이름
  + field : 오류 필드
  + `rejectedValue : 사용자가 입력한 값(거절된 값)`
  + bindingFailure : 타입 오류 같은 바인딩 실패인지, 검증 실패인지 구분 값 
  + `codes : 메시지 코드` 
  + `arguments : 메시지에서 사용하는 인자`
  + defaultMessage : 기본 오류 메시지

- 기존에는 직접 메시지를 줬지만, 코드로 관리할 수 있다. 
  + 기존: `new FieldError("item", "itemName", "상품 이름은 필수입니다.")`
  + 코드로 관리: `new FieldError("item", "price", item.getPrice(), false, new String[] {"range.item.price"}, new Object[]{1000, 1000000}`
    - Object[]{1000, 1000000} 를 사용해서 코드의 {0} , {1} 로 치환할 값을 전달한다.
    
## bindingResult.rejectValue
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
- required.item.itemName 
- required.itemName 
- required.java.lang.String 
- required

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
    typeMismatch.java.lang.Integer=숫자를 입력해주세요. typeMismatch=타입 오류입니다.
    ```

# Validator
- 컨트롤러에 있는 검증 로직을 별도의 클래스로 분리하자. 
- 스프링은 검증을 체계적으로 제공하기 위해 다음 인터페이스를 제공한다.
- ```
  public interface Validator {
    boolean supports(Class<?> clazz);
    void validate(Object target, Errors errors);
  }
  ```
- `@InitBinder`에 추가하면 `@Validated`가 있는 컨트롤러 호출시마다 검증 로직이 실행된다. 
  + ```
    @InitBinder
    public void init(WebDataBinder dataBinder) {
        dataBinder.addValidators(itemValidator);
    }
    ```
  + ```
    public String addItemV6(@Validated @ModelAttribute Item item, BindingResult bindingResult, RedirectAttributes redirectAttributes, Model model) { }
    ```



# 정리 
- bindingResult.rejectValue() 호출
- MessageCodesResolver 를 사용해서 검증 오류 코드로 메시지 코드들을 생성
- Validator를 이용해 컨트롤러 호출시마다 검증


