import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.Arrays;

public class Main {
    public static void main(String[] args) throws IOException {
        String[] input = new String[2];
        int count = 0;                                              // count of pairs
        String line;
        while(!(line = getString()).isEmpty()){
            if((count+1)*2 >= input.length) {
                input = Arrays.copyOf(input, input.length*2);    // expand the array
            }
            String[] spl = line.split(" ");
            input[count*2] = spl[0];
            input[count*2+1] = spl[1];
            count++;
        }

        //group by pairs
        Pair[] pairs = new Pair[count];
        int pi = 0;
        for(int i = 0; i < count; i++){
            String key = input[i*2];
            for(Pair p: pairs){
                if(p == null) break;
                if(p.key.equals(key)){
                    key = null;          // key is not unique ->
                    break;
                }
            }
            if(key == null) continue;       // -> key is not unique

            int val = 0;
            int valCount = 0;
            for(int j = i; j < count; j++){
                if(input[j*2].equals(key)){
                    val += Integer.parseInt(input[j*2+1]);
                    valCount++;
                }
            }
            pairs[pi++] = new Pair(key, val/valCount);
        }

        sort(pairs, pi);
        printKeys(pairs);
    }

    static void printKeys(Pair[] ar){
        for(Pair p: ar){
            if(p == null) return;
            System.out.println(p.key + " "+ p.avg);
        }
    }
    static String getString() throws IOException {
        InputStreamReader isr = new InputStreamReader(System.in);
        BufferedReader br = new BufferedReader(isr);
        return br.readLine();
    }
    static void sort(Pair[] ar, int len){
        for (int i = len-1;i>0;i--){
            for (int j=0;j<i;j++){
                if (ar[j].avg<ar[j+1].avg){
                    Pair t = ar[j];
                    ar[j]=ar[j+1];
                    ar[j+1]=t;
                }
            }
        }
    }
}

class Pair {
    public String key;
    public int avg;
    public Pair(String k, int a){
        key = k;
        avg = a;
    }
}
