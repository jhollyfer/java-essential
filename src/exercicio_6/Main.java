package exercicio_6;

import java.util.*;

public class Main {
    private static final Scanner input = new Scanner(System.in);
    private static final List<Employee> employees = new ArrayList<Employee>();
    private static final Map<Role, Integer> quantityPerPage = new HashMap<Role, Integer>();

    static void main() {
        int option;

        do {
            showMenu();
            System.out.print("Insert option: ");
            option = input.nextInt();

            switch (option) {
                case 1:
                    createEmployee();
                    break;
                case 2:
                    findManyEmployee();
                    break;
                case 3:
                    showFinalSalary();
                    break;
                case 4:
                    showHighestSalary();
                    break;
                case 5:
                    showQuantityPerPage();
                    break;
                case 6:
                    getByName();
                    break;
                default:
                    System.out.println("Invalid option.");
            }
        } while (option != 7);
    }


    private static void showMenu() {
        System.out.println("""
                    1 - Create employee
                    2 - List employees
                    3 - Show final salaries
                    4 - Employee with highest salary
                    5 - Number of employees per position
                    6 - Find employee by name
                    7 - Exit
                """);
    }

    private static void createEmployee() {
        System.out.print("Insert name: ");
        String name = input.next();

        System.out.print("Insert salary: ");
        double salary = input.nextDouble();

        System.out.print("Insert role: ");
        Role role = Role.valueOf(input.next());

        employees.add(new Employee(name, salary, role));

    }

    private static void findManyEmployee() {

        if (employees.isEmpty())
            System.out.println("Empty result");


        if (!employees.isEmpty())
            for (Employee employee : employees) {
                System.out.println("Name: " + employee.getName());
                System.out.println("Role: " + employee.getRole().getDescription());
            }
    }

    private static void showFinalSalary() {
        for (Employee employee : employees) {
            System.out.println("Name: " + employee.getName());
            System.out.println("Final Salary: " + employee.finalSalary());
        }
    }

    private static void showHighestSalary() {
        Employee highest = null;

        for (Employee employee : employees) {
            if (highest == null)
                highest = employee;
            else if (employee.finalSalary() > highest.finalSalary())
                highest = employee;

        }


        if (highest != null) {
            System.out.println("Name: " + highest.getName());
            System.out.println("Final Salary: " + highest.finalSalary());
        }

    }

    private static void showQuantityPerPage() {
        for (Employee employee : employees) {
            int quantity = quantityPerPage.getOrDefault(employee.getRole(), 0);
            quantityPerPage.put(employee.getRole(), quantity);
        }

        for (Map.Entry<Role, Integer> roleEntry : quantityPerPage.entrySet())
            System.out.println(roleEntry.getKey().getDescription() + " " + roleEntry.getValue());


    }

    private static void getByName() {
        System.out.print("Insert name: ");
        String name = input.next();

        for (Employee employee : employees) {
            if (employee.getName().equalsIgnoreCase(name)) {
                System.out.println("Name: " + employee.getName());
                System.out.println("Role: " + employee.getRole().getDescription());
                System.out.println("Final Salary: " + employee.finalSalary());
            }
        }
    }
}
