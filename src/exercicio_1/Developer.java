package exercicio_1;

public class Developer extends  Employee{

    @Override
    double bonus() {
        return this.getSalary() * 1.15;
    }

    @Override
    String role() {
        return "Developer";
    }
}
