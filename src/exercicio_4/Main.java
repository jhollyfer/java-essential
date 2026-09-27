package exercicio_4;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

public class Main {
    static void main() {
        Employee developer1 = new Developer();
        developer1.setName("Joao");
        developer1.setEmail("joao@mail.com");
        developer1.setSalary(8000);

        Employee developer2 = new Developer();
        developer2.setName("Joana");
        developer2.setEmail("joana@mail.com");
        developer2.setSalary(9000);

        Employee devops = new DevOps();
        devops.setName("Maria");
        devops.setEmail("maria@mail.com");
        devops.setSalary(10000);

        Employee pm = new ProductManager();
        pm.setName("lucas");
        pm.setEmail("lucas@mail.com");
        pm.setSalary(9500);

        List<Employee> employees = new ArrayList<Employee>(Arrays.asList(developer1, developer2, devops, pm));
        List<Employee> employeesEarningAbove10K = new ArrayList<Employee>();

        for (Employee employee : employees) {
            if (employee.bonus() > 10_000)
                employeesEarningAbove10K.add(employee);
        }

        System.out.println("Employees Earning Above 10K: ");
        for (Employee employee : employeesEarningAbove10K)
            System.out.println(employee.getName());

    }
}
