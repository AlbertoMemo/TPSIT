package org.example;


import java.util.Scanner;
import java.util.concurrent.Semaphore;

public class Main {
    public static void main(String[] args) {
        Scanner kbd = new Scanner(System.in);
        System.out.print("Dimensione n matrice (nxn): ");
        int n = kbd.nextInt();
        System.out.println();
        MatrixUtils utils = new MatrixUtils();

        int[][] A = utils.generateMatrix(n);
        int[][] B = utils.generateMatrix(n);
        int[][] result = new int[n][n];

        System.out.println("Matrice A:");
        utils.printMatrix(A);

        System.out.println("\nMatrice B:");
        utils.printMatrix(B);

        Semaphore semaphore = new Semaphore(0);

        Thread[][] threads = new Thread[n][n];
        for (int i = 0; i < n; i++) {
            for (int j = 0; j < n; j++) {
                threads[i][j] = new MultiplicationThread(A, B, result, i, j, semaphore);
                threads[i][j].start();
            }
        }

        try {
            semaphore.acquire(n * n);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }

        System.out.println("\nMatrice Prodotto:");
        utils.printMatrix(result);

        SumThread sumThread = new SumThread(result);
        sumThread.start();

        try {
            sumThread.join();
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
    }
}
