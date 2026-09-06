package EX_1;

public abstract class Employee extends  Person{
    private double salary;

    public Employee(){}

    public Employee(double salary) {
        this.salary = salary;
    }

    public double getSalary() {
        return salary;
    }

    public void setSalary(double salary) {
        this.salary = salary;
    }

    abstract  double bonus();
    abstract String role();

    void detail(){
        System.out.println("Name: " + this.getName());
        System.out.println("Role: " + this.role());
        System.out.println("Salary: " + this.bonus());
    }
}
