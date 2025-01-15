package TrisMain;
public class Main {
    public static void main(String[] args) {
        Tris tris = new Tris();
        Player giocatoreX = new Player(tris, 'X');
        Player giocatoreO = new Player(tris, 'O');

        giocatoreX.start();
        giocatoreO.start();

        try {
            giocatoreX.join();
            giocatoreO.join();
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }

        char vincitore = tris.controllaVincitore();
        if (vincitore != '-') {
            System.out.println("Giocatore " + vincitore + " ha vinto!");
        } else {
            System.out.println("Pareggio!");
        }
    }
}

