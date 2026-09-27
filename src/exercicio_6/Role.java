package exercicio_6;

public enum Role {
    DEVELOPER("Developer"),
    DEVOPS("DevOps"),
    PRODUCT_MANAGER("Product Manager");

    private String description;

    Role(String description){
        this.description = description;
    }


    public String getDescription(){
        return  this.description;
    }
}
