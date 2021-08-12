# 스프링 프레임워크 
- 핵심기술: 스프링 DI 컨테이너, AOP, 이벤트, 기타 
- 웹 기술: 스프링 MVC, 스프링 WebFlux
- 데이터 접근 기술: 트랜잭션, JDBC, ORM 지원, XML 지원 
- 기술 통합: 캐시, 이메일, 원격접근, 스케줄링 
- 테스트: 스프링 기반 테스트 지원 
- 언어: 코틀린, 그루비  

# 스프링 부트 
- 톰캣이 내장되어 있어서 별도의 웹서버를 설치하지 않아도 됨 
- starter로 손쉬운 종속성 제공 
- 스프링과 3rd parth(외부) 라이브러리 자동 구성. 외부 라이브러리 버전을 알아서 관리해줌. 즉, 잘 호환되는 버전을 알아서 가져다 씀. 
- 관례에 의한 간결한 설정 


# 스프링의 진짜 핵심
- 자바 언어의 가장 큰 특징 - 객체 지향 언어  
- 스프링은 `좋은 객체 지향 애플리케이션을 개발`할 수 있게 도와주는 프레임워크
- 좋은 객체 지향은 뭘까?

# 객체 지향 특징 
- 추상화 
- 캡슐화 
- 상속 
- 다형성 

# 객체 지향 설계 
- 모든 설계에 `역할`과 `구현`을 분리하자. 

# SOLID. 객체 지향 설계의 5가지 원칙 
## SRP. 단일 책임 원칙 
- 한 클래스는 하나의 책임만 가져야 한다. 

## `OCP`(Open Closed principle). 개방-폐쇄 원칙 
- 소프트웨어 요소는 `확장에는 열려있으나 변경에는 닫혀` 있어야 한다. 
- `다형성`을 활용. MemoryMemberRepository -> JdbcMemberRepository로 변경
- 
 ```
 public class MemberService { 
    private MemberRepository memberRepository = new MemoryMemberRepository();
 }
 ```
- 
 ```
 public class MemberService { 
//  private MemberRepository memberRepository = new MemoryMemberRepository();
    private MemberRepository memberRepository = new JdbcMemberRepository();
 }  
 ```
- 다형성을 이용해 OCP 원칙을 지키려 했지만, 구현 객체를 변경하려면 클라이언트 코드를 변경해야 한다. 확장은 열려있지만, 변경은 필요하므로 OCP 원칙을 지킬 수 없다. 
- 이 문제를 해결하기 위해 객체를 생성하고, 연관관계를 맺어주는 별도의 조립, 설정자가 필요함. => 스프링

## LSP. 리스코프 치환 원칙 
- 객체는 프로그램의 정확성을 꺠뜨리지 않으면서 하위 타입의 인스턴스로 바꿀 수 있어야 한다. 
- 다형성에서 하위 클래스는 인터페이스 규약을 다 지켜야 한다. 단순히 컴파일에 성공하는 것을 넘어서는 얘기 
- ex) 자동차 인테퍼에스의 엑셀은 앞으로 가라는 기능. 뒤로 가게 구현하면 LSP 위반

## ISP. 인터페이스 분리 원칙 
- 특정 클라이언트를 위한 인터페이스 여러 개가 범용 인터페이스 하나보다 낫다. 
- 인터페이스가 명확해지고, 대체 가능성이 높아진다. 
 
## `DIP`(Dependency inversion principle). 의존관계 역전 원칙 
- 프로그래머는 `추상화에 의존해야지, 구체화에 의존하면 안된다.` 의존성 주입은 이 원칙을 따르는 방법 중 하나. 
- 클라이언트가 구현체에 의존하지 말고 인터페이스에 의존해라.
- 그런데 OCP에서 설명한 MemberService는 인터페이스에 의존하지만, 구현 클래스도 동시에 의존한다. => DIP 위반
  + `MemberRepository memberRepository = new MemoryMemberRepository();'

## 정리 
- 다형성만으로는 쉽게 부품을 갈아 끼우듯이 개발할 수 없다. 
- 다형성만으로는 구현 객체를 변경할 때 클라이언트 코드도 함계 변경된다. 
- 다형성만으로는 OCP, DIP를 지킬 수 없다. 
- 인터페이스를 무분별하게 도입하면 추상화라는 비용이 발생. 이게 무슨 말이냐면, 인터페이스만 보고 구현 클래스를 알 수 없으니 어떤게 사용되고 있는지 찾아야함. 
- 기능을 확장할 가능성이 없다면, 구체 클래스를 직접 사용하고, 필요시 향후 리팩토링을 통해 인터페이스를 도입하는 것도 방법. 
- `스프링은 DI, DI 컨테이너 기술로 다형성 + OCP, DIP를 가능하게 지원. 클라이언트 코드의 변경 없이 기능 확장 가능.`

# 스프링 - 객체 지향 원리 적용 
## 새로운 할인 정책 개발. FixDiscountPolicy 
- 요구사항 수정이 발생함. 할인 정책을 고정 정책에서 정률 할인 정책으로 변경해야함. 
- OrderServiceImpl에서 기존 FixDiscountPolicy 대신 RateDiscountPolicy를 생성하여 교체하면 될 것 같아보임. 과연 그럴까?
- 기존 OrderServiceImpl를 살펴보면 추상(인터페이스) 뿐만 아니라 구체(구현) 클래스에도 의존하고 있으므로 DIP를 위반하고 있었음.
  + 추상 클래스: DiscountPolicy
  + 구체 글래스: FixDiscountPolicy, RateDiscountPolicy  
- 
```java 
  public class OrderServiceImpl implements OrderService {
//  private final DiscountPolicy discountPolicy = new FixDiscountPolicy; 
    private final DiscountPolicy discountPolicy = new RateDiscountPolicy;
  }
```
- 여기서 정률 할인 정책으로 바꾸면, 클라이언트 코드를 수정해야 하므로 OCP도 위반하게됌
  + OrderServiceImpl가 DiscountPolicy를 가져다 사용하는 입장이므로 클라이언트로 볼 수 있음.  
- 즉, OrderServiceImpl는 DiscountPolicy의 인터페이스 뿐만 아니라 구체 클래스도 의존하고 있으므로 추상에만 의존하도록 변경해야함. => DIP 만족 
- 
```java 
public class OrderServiceImpl implements OrderService { 
    private final DiscountPolicy discountPolicy;
}
```
- 하지만 구현체가 없으므로 NPE가 발생함. 이를 해결하기 위해서는 누군가가 DiscountPolicy 구현체를 넣어줘서 올바르게 동작할 수 있도록 해야함. 

## 관심사의 분리. AppConfig 
- 애플리케이션을 하나의 공연이라 생각해보자. 각각의 인터페이스는 배역이다. 인터페이스에 맞는 배역을 맡도록 배우를 지정해줘야 하는데.. 그 역할은 누가 하는가? 
- 로미오와 줄리엣에서 누가 로미오를 할지, 누가 줄리엣을 할지는 배우들이 정하는게 아니라 다른 이가 지정을 해줘야 한다. 이전 코드는 마치 로미오 역할(인터페이스)을 하는 레오나르도 디카프리오(구현체, 배우)가 줄리엣 역할(인터페이스)을 하는 여자 주인공(구현체, 배우)을 직접 초빙하는 것과 같다. 디카프리오는 공연도 해야하고 동시에 여자 주인공도 공연에 직접 초빙해야 하는 다양한 책임을 가지고 있다.
- 배우는 배역에만 집중해야한다. 공연을 구성하고, 담당 배우를 섭외하는 등의 역할을 하는 별도의 `공연 기획자`가 필요하다.
- 구현 객체를 생성하고, 연결하는 책임을 갖는 AppConfig가 필요하다. AppConfig는 생성자를 통해서 주입해준다. 
- `OrderServiceImpl은 이제부터 의존관계에 대한 고민은 외부에 맡기고 실행에만 집중하면 된다. 추상에만 의존하고 구체 클래스를 몰라도됌. => DIP 만족`
- 정리 
  + 공연 기획자: AppConfig 
  + 배역: OrderService, MemberRepository, DiscountPolicy
  + 배우: OrderServliceImpl, MemoryMemberRepository, FixDiscountPolicy, RateDiscountPolicy
  
## 정리 
- AppConfig에서 `FixDiscountPolicy` -> `RateDiscountPolicy`로 새로운 할인 정책으로 변경했다.
- 이제 할인 정책을 변경해도, 애플리케이션의 구성 역할을 담당하는 AppConfig만 변경하면 된다. 클라이언트 코드인 OrderServiceImpl 를 포함해서 사용 영역의 어떤 코드도 변경할 필요가 없다.
- 구성 영역은 당연히 변경된다. 구성 역할을 담당하는 AppConfig를 애플리케이션이라는 공연의 기획자로 생각하자. 공연 기획자는 공연 참여자인 구현 객체들을 모두 알아야 한다.
- 이제부터 클라이언트 객체는 자신의 역할을 실행하는 것만 집중, 권한이 줄어듬(책임이 명확해짐)

# 스프링 컨테이너 생성 
- 
```java
//스프링 컨테이너 생성
ApplicationContext applicationContext = new AnnotationConfigApplicationContext(AppConfig.class);
```
- ApplicationContext는 인터페이스이고, 스프링 컨테이너라 한다. 
- 스프링 컨테이너는 애노테이션 기반의 자바 설정 클래스나, XML 기반으로 만들 수 있다. 

## 스프링 컨테이너의 생성 과정 
- 1. 스프링 컨테이너 생성 
  + new AnnotationConfigApplicationContext(AppConfig.class)
- 2. 스프링 빈 등록 
  + @Bean으로 지정된 어노테이션을 찾아서 스프링 빈으로 등록한다. 
  + ````
       빈 이름         |  빈 객체 
    memberService    | MemberServiceImpl@x01
    orderService     | OrderServiceImpl@x02
    memberRepository | MemoryMemberRepository@x03
    discountPolicy   | RateDiscountPolicy@x04
    ````
- 3. 스프링 빈 의존관계 설정 
  + 스프링 컨테이너는 설정 정보를 참고해서 의존관계를 주입한다. 
  + ```
    @Bean
    public MemberService memberService() {
      return new MemberServiceImpl(memberRepository()); 
    }
    ```

# 스프링 빈 조회 - 상속 관계 
- 부모 타입으로 조회하면, 자식 타입도 함께 조회할 수 있다. 
- Object로 조회하면, 모든 스프링 빈을 조회할 수 있다. 

# BeanFactory와 ApplicationContext 

## BeanFactory
- 스프링 컨테이너의 최상위 인터페이스 
- 빈을 관리하고 조회하는 역할을 담당. `getBean()`

## ApplicationContext
- BeanFactory 기능을 모두 상속받아서 제공한다. 즉, BeanFactory + 편리한 부가 기능   
- MessageSource. 국제화 기능
- EnvironmentCapable. 환경 변수
  + 로컬, 개발, 운영등을 구분해서 처리  
- ApplicationEventPublisher. 애플리케이션 이벤트 
  + 이벤트를 발행하고 구독하는 모델을 편리하게 지원 
- ResourceLoader. 편리한 리소스 조회 
  + 파일, 클래스패스, 외부 등에서 리소스를 편리하게 조회 
  
# 스프링 빈 설정 메타 정보 - BeanDefinition
- 스프링 컨테이너는 다양한 형식의 빈 설정 정보를 받아드릴 수 있게 설계되어 있다. 자바코드, XML, Groovy 등
  + 빈 하나가 하나의 메타정보라고 이해하면 됌. 
- BeanDefinition으로 추상화 시켜놓고 ApplicationContext가 이를 가져다 쓰도록 되어있음. 스프링 컨테이너는 빈 정보가 자바 코드인지, XML인지 알 필요가 없다.
- AnnotationConfigApplicationContext는 AnnotatedBeanDefinitionReader를 사용해서 AppConfig.class를 읽고 BeanDefinition을 생성한다.
- GenericXmlApplicationContext는 XmlBeanDefinitionReader를 사용해서 appConfig.xml 설정 정보를 읽고 BeanDefinition을 생성한다.

## BeanDefinition 정보 
- beanDefinitionName = memberService beanDefinition = Root bean: class [null]; scope=; abstract=false; lazyInit=null; autowireMode=3; dependencyCheck=0; autowireCandidate=true; primary=false; factoryBeanName=appConfig; factoryMethodName=memberService; initMethodName=null; destroyMethodName=(inferred); defined in hello.core.AppConfig

## 정리 
- 스프링은 빈의 설정 정보를 BeanDefinition으로 추상화해서 사용한다. 

# 싱글톤 컨테이너 
## 스프링이 없는 순수한 DI 컨테이너  
- 스프링이 없는 순수한 DI 컨테이너인 AppConfig는 요청할 때마다 객체를 새로 생성한다. `SingletonTest.pureContainer()` 
- 매번 새로 객체를 생성하는건 메모리 낭비가 심하므로 싱글톤 패턴으로 객체를 설계하는 게 좋다.  

## 싱글톤 패턴 
- 애플리케이션 내에 클래스의 인스턴스가 딱 1개만 생성되는 디자인 패턴이다. `SingletonService`, `SingletonServiceTest`

## 싱글톤 패턴 문제점 
- 싱글톤 패턴을 구현하는 코드가 많이 필요함 
- 의존관계상 클라이언트가 구체 크래스에 의존한다. -> DIP 위반 
- 클라이언트가 구체 클래스에 의존해서 OCP 원칙을 위반할 가능성 높음 
- 테스트하기 어렵다. 
- 상속 불가. 유연성이 떨어진다. 

## 싱글톤 컨테이너 
- 스프링 컨테이너는 싱글턴 패턴을 적용하지 않아도, 객체 인스턴스를 싱글톤으로 관리함. 
- 스프링 컨테이너는 싱글톤 컨테이너 역할을 한다. == 싱글톤 레지스트리 
- 스프링 컨테이너의 이런 기능 덕분에 싱글턴 패턴의 모든 단점을 해결하면서 객체를 싱글톤으로 유지할 수 있다. 
  + 싱글톤으로 만들기 위한 지저분한 코드 생략 가능 
  + DIP, OCP, 테스트, private 생성자로부터 자유롭게 싱글톤을 유지할 수 있다. 

## 싱글톤 방식의 주의점 
- 여러 클라이언트에서 하나의 인스턴스를 공유하는 것이기 때문에 싱글톤 객체는 상태를 유자히게 설계하면 안된다. 
- 무상태(stateless)로 설계해야함. 
  + 객체 내부에 클라이언트가 값을 변경할 수 있는 필드가 있으면 안됨. 
  + 객체 내부에 필드가 있다면 가급적 읽기만 가능해야함. 
- `스프링 빈은 항상 무상태(stateless)로 설계해야한다.`

## @Configuration과 바이트코드 조작의 마법 
- @Configuration이 붙으면 CGLIB가 바이트코드를 조작해 AppConfig 클래스를 상속받아 임의의 다른 클래스를 만들고, 그 클래스를 스프링 빈으로 등록한다. 
- 이런 느낌의 코드 
  + ```
    @Bean
    public MemberRepository memberRepository() {
       if (memoryMemberRepository가 이미 스프링 컨테이너에 등록되어 있으면?) {
           return 스프링 컨테이너에서 찾아서 반환;
       } else { //스프링 컨테이너에 없으면
         기존 로직을 호출해서 MemoryMemberRepository를 생성하고 스프링 컨테이너에 등록
         return 반환
       }
    }
    ```
- `@Configuration이 없고 @Bean만 있으면 스프링 빈으로 등록되지만, 싱글톤은 보장하지 않는다.` 
 

# 컴포넌트 스캔

## 컴포넌트 스캔과 의존관계 자동 주입하기 
- 지금까지 스프링 빈을 등록할때, AppConfig에서 직접 빈 만들어서 등록을 해줬다. 
- 이 방법은 스프링 빈이 많아지면 사용하기 어렵다. 그래서 자동으로 스프링 빈을 등록하는 `컴포넌트 스캔`이라는 기능을 제공한다.
- 또 `@Autowired`로 의존관계도 자동으로 주입할 수 있다.    
- 기존의 AppConfig와 다르게 @Bean으로 등록한 클래스가 없다. @Component로 등록함.

## @ComponentScan 
- @ComponentScan은 @Component가 붙은 모든 클래스를 스프링 빈으로 등록한다. 
  + 스프링 빈의 기본 이름은 클래스명을 사용하되 맨 앞글자만 소문자를 사용한다. 
  + MemberServiceImpl -> memberServiceImpl 
- 보통 basePackages, basePackageClasses로 클래스 위치를 지정하지 않고, 설정 정보 클래스 위치를 프로젝트 최상단에 두어 전체를 스캔하도록 둔다.
- 컴포넌트 스캔은 @Component 뿐만 아니라 다음 대상도 포함한다. 
  + `@Component`: 컴포넌트 스캔에서 사용 
  + `@Controller`: 스프링 MVC 컨트롤러에서 사용 
  + `@Service`: 스프링 비즈니스 로직에서 사용. 추가기능 없음.  
  + `@Repository`: 스프링 데이터 접근 계층에서 사용. 데이터 계층의 예외를 스프링 예외로 변환해줌  
  + `@Configuration`: 스프링 설정 정보에서 사용. 스프링 빈이 싱글톤을 유지하도록 해줌    

## @Autowired
- 생성자에 `@Autowired`를 지정하면, 스프링 컨테이너가 자동으로 빈을 찾아서 주입한다. 
  + ac.getBean(MemberRepository.class)

## 필터 
- `includeFilters`, 컴포넌트 스캔 대상 추가 
- `excludeFilters`, 컴포넌트 스캔 대상 제외 

## 빈 중복 등록과 충돌 
- 자동 빈 등록 vs 자동 빈 등록 
  + `ConflictingBeanDefinitionException` 예외 발생 
- 자동 빈 등록 vs 수동 빈 등록 
  + 스프링 -> 수동 빈이 오버라이딩된다.
  + 스프링 부트 -> 에러남  