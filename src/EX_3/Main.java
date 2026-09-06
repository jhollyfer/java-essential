package EX_3;

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

        Employee highestPaidEmployee = null;

        for (Employee employee : employees) {
            if (highestPaidEmployee == null)
                highestPaidEmployee = employee;
            else if (employee.getSalary() > highestPaidEmployee.getSalary())
                highestPaidEmployee = employee;
        }

        System.out.println("Highest Paid Employee: " + highestPaidEmployee.getName());

    }
}
