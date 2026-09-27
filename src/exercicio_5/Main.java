package exercicio_5;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class Main {
    static void main() {
        Employee f1 = new Employee("Matheus", Role.DEVELOPER);
        Employee f2 = new Employee("Thiago", Role.DEVELOPER);
        Employee f3 = new Employee("Lucas", Role.PRODUCT_MANAGER);
        Employee f4 = new Employee("Pedro", Role.DEVOPS);

        List<Employee> employees = new ArrayList<Employee>(Arrays.asList(f1, f2, f3, f4));
        Map<Role, Integer> mapEmployee = new HashMap<Role, Integer>();

        for (Employee employee : employees) {
            int roleQuantity = mapEmployee.getOrDefault(employee.getRole(), 0);
            mapEmployee.put(employee.getRole(), roleQuantity + 1);
        }

        // System.out.println(mapEmployee);

        for (Map.Entry<Role, Integer> roleMapping : mapEmployee.entrySet()) {
            Role role = roleMapping.getKey();
            Integer quantity = roleMapping.getValue();

            System.out.println("Role: " + role + " - Quantity: " + quantity);
        }

    }
}
