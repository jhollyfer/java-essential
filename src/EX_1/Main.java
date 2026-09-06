package EX_1;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

public class Main {
    static  void main(){
        Employee developer = new Developer();
        developer.setName("Joao");
        developer.setEmail("joao@mail.com");
        developer.setSalary(8000);

        Employee devops = new DevOps();
        devops.setName("Maria");
        devops.setEmail("maria@mail.com");
        devops.setSalary(10000);

        Employee pm = new ProductManager();
        pm.setName("lucas");
        pm.setEmail("lucas@mail.com");
        pm.setSalary(9000);

        List<Employee> employees = new ArrayList<Employee>(Arrays.asList(developer, devops, pm));

        double totalPayment = 0;

        for(Employee employee: employees){
            System.out.println("-------------------------");
            employee.detail();
            totalPayment += employee.getSalary();
        }

        System.out.println("Total Employees: " + employees.size());
        System.out.println("Total payment: " + totalPayment);

    }
}
