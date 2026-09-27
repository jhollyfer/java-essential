package exercicio_1;

public class DevOps extends Employee{

    @Override
    double bonus() {
        return this.getSalary() * 1.10;
    }

    @Override
    String role() {
        return "DevOps";
    }
}
