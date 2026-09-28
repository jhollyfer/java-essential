package exercicio_6;

public enum Role {
    DEVELOPER("Developer"){
        @Override
        double bonus(double salary) {
            return salary * 0.10;
        }
    },
    DEVOPS("DevOps"){
        @Override
        double bonus(double salary) {
            return salary * 0.15;
        }
    },
    PRODUCT_MANAGER("Product Manager"){
        @Override
        double bonus(double salary) {
            return salary * 0.20;
        }
    };


    private final String description;

    abstract double bonus(double salary);

    Role(String description){
        this.description = description;
    }


    public String getDescription(){
        return  this.description;
    }
}
