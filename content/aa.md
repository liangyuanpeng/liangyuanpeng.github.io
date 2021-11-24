
# 简介
学习设计原则，是学习设计模式的基础。在实际开发过程中，并不是一定要求所有代码都遵循设计原则，我们要考虑人力、时间、成本、质量，不是刻意追求完美，要在适当场景遵循设计原则，体现的是一种平衡取舍，帮助我们设计出更加优雅的代码结构
​

# 开闭原则（Open-Closed Principle，OCP）

开闭原则是指一个软件实体如类、模块和函数应该对扩展开放，对修改关闭。

所谓的关闭，也正是对扩展和修改两个行为的一个原则。强调的是用抽象构建框架，用实现扩展细节。可以提高软件系统的可复用性及可维护性。

开闭原则，是面向对象设计中最基础的设计原则。它指导我们如何建立稳定灵活的系统，例如：我们版本更新，我们尽可能不修改源代码，但是可以增加新功能。
​

如下：有一个课程接口和Java课程类

```java
public interface ICourse {
    Integer getId();

    String getName();

    Double getPrice();
}



public class JavaCourse implements ICourse {
    private Integer id;
    private String name;
    private Double price;

    public JavaCourse(Integer id, String name, Double price) {
        this.id = id;
        this.name = name;
        this.price = price;
    }

    @Override
    public Integer getId() {
        return this.id;
    }

    @Override
    public String getName() {
        return this.name;
    }

    @Override
    public Double getPrice() {
        return this.price;
    }
}
```

现在想要给java课程做活动，有折扣价，如果直接修改JavaCourse中的getPrice()方法，则会存在一定的风险，可能影响其他地方原有的调用。

在不修改原有代码的前提下，可以新增一个有折扣的课程接口，并且新增一个有折扣的Java课程类

```java
public interface IDiscountCourse extends ICourse {
    Double getDiscountPrice();
}


public class JavaDiscountCourse extends JavaCourse implements IDiscountCourse {
    public JavaDiscountCourse(Integer id, String name, Double price) {
        super(id, name, price);
    }

    @Override
    public Double getDiscountPrice() {
        return getPrice() * 0.6;
    }
}
```

这样，使用的时候可以选择有折扣或者没有折扣

```java
@Slf4j
public class OcpTest {
    public static void main(String[] args) {
        
        ICourse course = new JavaCourse(1, "Java编程思想", 110d);
        log.info("课程ID：{}，名称：{}，原价：{}",
                course.getId(),
                course.getName(),
                course.getPrice());
        
        IDiscountCourse course2 = new JavaDiscountCourse(1, "Java编程思想", 110d);
        log.info("课程ID：{}，名称：{}，原价：{}，折扣价：{}",
                course2.getId(),
                course2.getName(),
                course2.getPrice(),
                course2.getDiscountPrice());
    }
}
```

类图如下

# 依赖倒置原则（Dependence Inversion Principle，DIP）

依赖倒置原则是指设计代码结构时，高层模块不应该依赖底层模块细节，二者都应该依赖其抽象。抽象不应该依赖细节，细节应该依赖抽象。

通过依赖倒置，可以减少类与类之间的耦合性，提高系统的稳定性，提高代码的可读性和可维护性，并能够降低修改程序所造成的的风险。
​

如下，汽车系统类直接依赖具体的汽车实现类，如果需要再兼容一个品牌的汽车，则汽车系统类的所有方法都需要同步修改

```java
public class HondaCar {
    public void run() {
        System.out.println("本田汽车启动了");
    }

    public void turn() {
        System.out.println("本田汽车转弯了");
    }

    public void stop() {
        System.out.println("本田汽车停车了");
    }
}


public class FordCar {
    public void run() {
        System.out.println("福特汽车启动了");
    }

    public void turn() {
        System.out.println("福特汽车转弯了");
    }

    public void stop() {
        System.out.println("福特汽车停车了");
    }
}


public class CarSystem {
    public enum CarType {
        Honda, Ford
    }

    private HondaCar hondaCar = new HondaCar();
    private FordCar fordCar = new FordCar();
    private CarType carType;

    public CarSystem(CarType carType) {
        this.carType = carType;
    }

    public void runCar() {
        switch (carType) {
            case Honda:
                hondaCar.run();
                break;
            case Ford:
                fordCar.run();
                break;
            default:
        }
    }

    public void turnCar() {
        switch (carType) {
            case Honda:
                hondaCar.turn();
                break;
            case Ford:
                fordCar.turn();
                break;
            default:
        }
    }

    public void stopCar() {
        switch (carType) {
            case Honda:
                hondaCar.stop();
                break;
            case Ford:
                fordCar.stop();
                break;
            default:
        }
    }
}


public class DipTest {
    public static void main(String[] args) {
        CarSystem carSystem = new CarSystem(CarSystem.CarType.Ford);
        carSystem.runCar();
        carSystem.turnCar();
        carSystem.stopCar();
    }
}
```

为此，我们抽象一个汽车接口出来，然后每个品牌的汽车都实现它，汽车系统直接依赖汽车接口，不再关注每个品牌的实现。

这样，即使需要再新增一个品牌的汽车，只需要新增一个类实现汽车接口，并且修改客户端代码即可，不需要对汽车系统类做任何改动。

```java
public interface ICar {
    void run();
    void turn();
    void stop();
}


public class HondaCar implements ICar {
    @Override
    public void run() {
        System.out.println("本田汽车启动了");
    }

    @Override
    public void turn() {
        System.out.println("本田汽车转弯了");
    }

    @Override
    public void stop() {
        System.out.println("本田汽车停车了");
    }
}


public class FordCar implements ICar {
    @Override
    public void run() {
        System.out.println("福特汽车启动了");
    }

    @Override
    public void turn() {
        System.out.println("福特汽车转弯了");
    }

    @Override
    public void stop() {
        System.out.println("福特汽车停车了");
    }
}


public class CarSystem {
    private ICar car;

    public CarSystem(ICar car) {
        this.car = car;
    }

    public void runCar() {
        car.run();
    }

    public void turnCar() {
        car.turn();
    }

    public void stopCar() {
        car.stop();
    }
}


public class DipTest {
    public static void main(String[] args) {
        CarSystem carSystem = new CarSystem(new FordCar());
        carSystem.runCar();
        carSystem.turnCar();
        carSystem.stopCar();
    }
}
```

类图如下
image.png

# 单一职责原则（Simple Responsibility Principle）

单一职责是指不要存在多于一个导致类变更的原因。假设一个类负责两个职责，一旦需求变更，修改其中一个职责的逻辑代码，有可能会导致另一个职责的功能发生故障。这样这个类就存在两个导致类变更的原因了，我们就要给两个职责分别用两个类来实现。
​

如下，有一个课程类，可以播放直播课程和录播课程，不管哪一个课程的需求变更，都需要修改这个类，即存在多个原因导致类的变化

```java
public class Course {
    public void study(String courseName) {
        if ("直播课".equals(courseName)) {
            System.out.println("直播课程不能快进");
        } else if ("录播课".equals(courseName)) {
            System.out.println("录播课程可以任意切换进度");
        }
    }
}
```

我们可以将课程类进行拆分，让每一个类只负责一种课程，这样一种课程的修改不会影响到另外一个课程

```java
public class LiveCourse {
    public void study() {
        System.out.println("直播课程不能快进");
    }
}


public class ReplayCourse {
    public void study() {
        System.out.println("录播课程可以任意切换进度");
    }
}


public class SrpTest {
    public static void main(String[] args) {
        Course course = new Course();
        course.study("直播课");
        course.study("录播课");

        LiveCourse liveCourse = new LiveCourse();
        liveCourse.study();

        ReplayCourse replayCourse = new ReplayCourse();
        replayCourse.study();
    }
}
```

# 接口隔离原则（Interface Segregation Principle，ISP）

接口隔离原则是指用多个专门的接口，而不使用单一的总接口，客户端不应该依赖它不需要的接口。

这个原则指导我们在设计接口时应当注意一下几点：

一个类对一个类的依赖应该建立在最小的接口之上
建立单一接口，不要建立庞大臃肿的接口
尽量细化接口，接口中的方法尽量少（不是越少越好，一定要适度）
接口隔离原则符合我们常说的高内聚低耦合的设计思想，从而使得类具有很好的可读性、可扩展性和可维护性。我们在设计接口的时候，要多花时间去思考，要考虑业务模型，包括以后有可能发生变更的地方还要做一些预判。
​

如下，定义了一个动物的接口，有吃东西、飞翔、游泳方法，但是鸟不会游泳，狗不会飞翔，导致它们有一些空实现的方法

```java
public interface IAnimal {
    void eat();

    void fly();

    void swim();
}


public class Bird implements IAnimal {
    @Override
    public void eat() {
        System.out.println("鸟吃虫");
    }

    @Override
    public void fly() {
        System.out.println("鸟会飞");
    }

    @Override
    public void swim() {
        
    }
}


public class Dog implements IAnimal {
    @Override
    public void eat() {
        System.out.println("狗吃饭");
    }

    @Override
    public void fly() {
        
    }

    @Override
    public void swim() {
        System.out.println("狗会游泳");
    }
}
```

所以，我们应该进行接口隔离，不同动物实现各自的接口

```java
public interface IEatAnimal {
    void eat();
}


public interface IFlyAnimal {
    void fly();
}


public interface ISwimAnimal {
    void swim();
}


public class Bird implements IEatAnimal, IFlyAnimal {
    @Override
    public void eat() {
        System.out.println("鸟会吃东西");
    }

    @Override
    public void fly() {
        System.out.println("鸟会飞");
    }
}


public class Dog implements IEatAnimal, ISwimAnimal {
    @Override
    public void eat() {
        System.out.println("狗会吃东西");
    }

    @Override
    public void swim() {
        System.out.println("狗会游泳");
    }
}
```

对比两个类图
image.pngimage.png

# 迪米特法则（Law of Demeter，LOD）

迪米特法则是指一个对象应该对其他对象保持最少的了解，又叫最少知道原则（Least Knowledge Principle，LKP），尽量降低类与类之间的耦合。

迪特米法则主要强调只和朋友交流，不和陌生人说话。出现在成员变量、方法的输入、输出参数中的类都可以称为成员朋友类，而出现在方法内部的类不属于朋友类。
​

如下，老板让员工统计已发布的课程数量，功能是没有问题的

```java
public class Course {
}


public class Employee {

    
    public void countCourse(List<course> courses) {
        System.out.println("目前已发布的课程数量为" + courses.size());
    }
}


public class Boss {

    
    public void countCourse(Employee employee) {
        List<course> courseList = new ArrayList<course>();
        for (int i = 0; i < 20; i ++){
            courseList.add(new Course());
        }
        employee.countCourse(courseList);
    }
}


public class LodTest {
    public static void main(String[] args) {
        Employee employee = new Employee();
        Boss boss = new Boss();
        boss.countCourse(employee);
    }
}
```

但是老板其实只想要结果，不需要直接知道课程的细节，根据迪特米法则进行调整如下

```java
public class Course {
}


public class Employee {
    private List<course> courses;

    public Employee(List<course> courses) {
        this.courses = courses;
    }

    
    public void countCourse() {
        System.out.println("目前已发布的课程数量为" + courses.size());
    }
}


public class Boss {

    
    public void countCourse(Employee employee) {
        employee.countCourse();
    }
}


public class LodTest {
    public static void main(String[] args) {
        List<course> courseList = new ArrayList<course>();
        for (int i = 0; i < 20; i ++){
            courseList.add(new Course());
        }
        
        Employee employee = new Employee(courseList);
        Boss boss = new Boss();
        boss.countCourse(employee);
    }
}
```

类图对比如下
image.pngimage.png

# 里氏替换原则（Liskov Substitution Principle，LSP）

里氏替换原则是指如果对每一个类型为T1的对象o1，都有类型为T2的对象o2，使得以T1定义的所有程序p在所有的对象o1都替换成o2时，程序p的行为没有发生变化，那么类型T2是类型T1的子类型。

定义比较抽象，可以理解为一个软件实体如果适用一个父类的话，那一定适用于其子类，所以引用父类的地方必须能透明地使用其子类的对象，子类的对象能够替换父类的对象，而程序逻辑不变。
​

引申含义：子类可以扩展父类的功能，但不能改变父类原有的功能。

子类可以实现父类的抽象方法，但不能覆盖父类的非抽象方法
子类中可以增加自己特有的方法
当子类的方法重载父类的方法时，方法的前置条件（即方法的入参）要比父类方法的入参更宽松
当子类的方法实现父类的方法时（重写/重载或实现抽象方法），方法的后置条件（即方法的返回值）要比父类更严格或相等
优点：

约束继承泛滥，开闭原则的一种体现
加强程序的健壮性，同时变更时也可以做到非常好的兼容性，提高程序的维护性、扩展性。降低需求变更时引入的风险。
如下：
同样的方法入参，当调用method1时，都是执行父类的逻辑，属于遵循里氏替换原则，方法的入参要比父类方法的入参更宽松；
当调用method2时，使用子类对象时执行了子类的逻辑，属于违反里氏替换原则；

```java
public class Parent {
    
    public void method1(HashMap<string, string=""> map) {
        System.out.println("父类method1");
    }

    public void method2(Map map) {
        System.out.println("父类method2");
    }
}


public class Child extends Parent {
    public void method1(Map map) {
        System.out.println("子类method1");
    }
    
    public void method2(HashMap<string, string=""> map){
        System.out.println("子类method2");
    }
}


public class MethodParamTest {
    public static void main(String[] args) {
        Parent parent = new Parent();
        parent.method1(new HashMap<>());
        parent.method2(new HashMap<>());

        Child child = new Child();
        child.method1(new HashMap<>());
        child.method2(new HashMap<>());
    }
}


父类method1
父类method2
父类method1
子类method2
```

如下：当子类复写父类的方法时，而返回值比父类的更宽松，编译不通过，jdk本身提供了这个支持

```java
public class Parent {

    public HashMap<string, string=""> method1() {
        System.out.println("父类method1");
        return new HashMap<>();
    }
}


public class Child extends Parent {
    
    
    public Map<string, string=""> method1() {
        System.out.println("子类method1");
        return new HashMap<>();
    }
}
```

合成复用原则是指尽量使用对象组合（has-a）/ 聚合（contains-a），而不是继承关系达到软件复用的目的。可以使系统更加灵活，降低类与类之间的耦合度，一个类的变化对其他类造成的影响相对较少。

继承我们叫做白箱复用，相当于把所有实现细节暴露给子类。组合/聚合也称之为黑箱复用，对类以外的对象是无法获取到实现细节的。
​

如下，是一个非常典型的合成复用原则应用场景。

```java
public abstract class DBConnection {
    
    public abstract String getConnection();
}


public class MySQLConnection extends DBConnection {
    @Override
    public String getConnection() {
        return "MySQL数据库连接";
    }
}


public class OracleConnection extends DBConnection {
    @Override
    public String getConnection() {
        return "Oracle数据库连接";
    }
}


public class ProductDao {
    private DBConnection dbConnection;

    public ProductDao(DBConnection dbConnection) {
        this.dbConnection = dbConnection;
    }

    public void addProduct() {
        String connection = dbConnection.getConnection();
        System.out.println("获得：" + connection);
    }
}


public class CarpTest {
    public static void main(String[] args) {
        ProductDao productDao = new ProductDao(new MySQLConnection());
        productDao.addProduct();
    }
}
```

类图如下
image.png