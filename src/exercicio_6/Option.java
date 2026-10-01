package exercicio_6;

public enum Option {
    CREATE(1),
    FIND_MANY(2),
    FINAL_SALARY(3),
    HIGHEST_SALARY(4),
    PER_POSITION(5),
    FIND_BY_NAME(6);

    private final int value;

    Option(int value){
        this.value = value;
    }

    public  int getCode(){
        return this.value;
    }

}
