package TrisMain;
import java.util.concurrent.locks.ReentrantLock;

public class Tris {
    private final char[][] griglia = new char[3][3];
    private final ReentrantLock lucchetto = new ReentrantLock();

    public Tris() {
        for (int i = 0; i < 3; i++) {
            for (int j = 0; j < 3; j++) {
                griglia[i][j] = '-';
            }
        }
    }

    public boolean faiMossa(int riga, int colonna, char simbolo) {
        lucchetto.lock();
        try {
            if (griglia[riga][colonna] == '-') {
                griglia[riga][colonna] = simbolo;
                return true;
            }
            return false;
        } finally {
            lucchetto.unlock();
        }
    }

    public boolean piena() {
        lucchetto.lock();
        try {
            for (int i = 0; i < 3; i++) {
                for (int j = 0; j < 3; j++) {
                    if (griglia[i][j] == '-') {
                        return false;
                    }
                }
            }
            return true;
        } finally {
            lucchetto.unlock();
        }
    }

    public char controllaVincitore() {
        lucchetto.lock();
        try {
            for (int i = 0; i < 3; i++) {
                if (griglia[i][0] != '-' && griglia[i][0] == griglia[i][1] && griglia[i][1] == griglia[i][2]) {
                    return griglia[i][0];
                }
                if (griglia[0][i] != '-' && griglia[0][i] == griglia[1][i] && griglia[1][i] == griglia[2][i]) {
                    return griglia[0][i];
                }
            }
            if (griglia[0][0] != '-' && griglia[0][0] == griglia[1][1] && griglia[1][1] == griglia[2][2]) {
                return griglia[0][0];
            }
            if (griglia[0][2] != '-' && griglia[0][2] == griglia[1][1] && griglia[1][1] == griglia[2][0]) {
                return griglia[0][2];
            }
            return '-';
        } finally {
            lucchetto.unlock();
        }
    }

    public void stampaTris() {
        lucchetto.lock();
        try {
            for (int i = 0; i < 3; i++) {
                for (int j = 0; j < 3; j++) {
                    System.out.print(griglia[i][j] + " ");
                }
                System.out.println();
            }
            System.out.println();
        } finally {
            lucchetto.unlock();
        }
    }
}

