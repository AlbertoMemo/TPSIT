package org.example;

import java.util.concurrent.Semaphore;

public class MultiplicationThread extends Thread {
    private int[][] A;
    private int[][] B;
    private int[][] result;
    private int riga;
    private int colonna;
    private Semaphore semaphore;

    public MultiplicationThread(int[][] A, int[][] B, int[][] result, int row, int col, Semaphore semaphore) {
        this.A = A;
        this.B = B;
        this.result = result;
        this.riga = row;
        this.colonna = col;
        this.semaphore = semaphore;
    }

    @Override
    public void run() {
        int sum = 0;
        for (int k = 0; k < A.length; k++) {
            sum += A[riga][k] * B[k][colonna];
        }
        result[riga][colonna] = sum;
        semaphore.release();
    }
}