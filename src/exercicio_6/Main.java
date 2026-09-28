package exercicio_6;

import java.util.Scanner;

public class Main {
    static void main(){
        Scanner input = new Scanner(System.in);
        int option;

        do {
            showMenu();
            System.out.print("Digite opção: ");
            option = input.nextInt();
        } while (option != 7);
    }

    private static void showMenu(){
        System.out.println("""
         1 - Cadastrar funcionário
         2 - Listar funcionários
         3 - Exibir salários finais
         4 - Funcionário com maior salário
         5 - Quantidade de funcionários por cargo
         6 - Buscar funcionário por nome
         7 - Sair       
         """);
    }
}
