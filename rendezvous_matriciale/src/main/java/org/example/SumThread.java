package org.example;

public class SumThread extends Thread {
    private int[][] matrice;
    private int somma;

    public SumThread(int[][] matrice) {
        this.matrice = matrice;
        this.somma = 0;
    }

    @Override
    public void run() {
        int n = matrice.length;
        for (int i = 0; i < n; i++) {
            for (int j = 0; j < matrice[i].length; j++) {
                somma += matrice[i][j];
            }
        }
        System.out.println("\nSomma degli elementi della matrice prodotto: " + somma);
    }
}
