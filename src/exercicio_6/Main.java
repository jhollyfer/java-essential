package exercicio_6;

import java.util.ArrayList;
import java.util.List;
import java.util.Scanner;

public class Main {
    private static final Scanner input  = new Scanner(System.in);
    private static final List<Employee> employees = new ArrayList<Employee>();

    static void main(){
        int option;

        do {
            showMenu();
            System.out.print("Insert option: ");
            option = input.nextInt();

            switch (option){
                case 1:
                    createEmployee();
                    break;
                case 2:
                    findManyEmployee();
                    break;
                default:
                    continue;
            }
        } while (option != 7);
    }

    private static void showMenu(){
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

    private static void createEmployee(){
        System.out.print("Insert name: ");
        String name = input.next();

        System.out.print("Insert salary: ");
        double salary = input.nextDouble();

        System.out.print("Insert role: ");
        Role role = Role.valueOf(input.next());

        employees.add(new Employee(name, salary, role));

    }

    private static void findManyEmployee(){

        if(employees.isEmpty())
            System.out.println("Empty result");


        if(!employees.isEmpty())
            for(Employee employee: employees){
                System.out.println("Name: " + employee.getName());
            }
    }
}
