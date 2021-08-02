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