package TrisMain;
import java.util.Random;

public class Player extends Thread {
    private Tris tris;
    private char simbolo;
    private Random random = new Random();

    public Player(Tris tris, char simbolo) {
        this.tris = tris;
        this.simbolo = simbolo;
    }

    @Override
    public void run() {
        while (!tris.piena() && tris.controllaVincitore() == '-') {
            int riga = random.nextInt(3);
            int colonna = random.nextInt(3);
            try {
                Thread.sleep(500 + random.nextInt(501));
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
                return;
            }
            if (tris.faiMossa(riga, colonna, simbolo)) {
                System.out.println("Giocatore " + simbolo + " ha fatto una mossa in (" + riga + ", " + colonna + ")");
                tris.stampaTris();
            }
        }
    }
}
