package exercicio_4;

public class ProductManager extends Employee {

    @Override
    double bonus() {
        return this.getSalary() * 1.20;
    }

    @Override
    String role() {
        return "Product Manager";
    }
}
