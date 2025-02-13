package org.example;

import javax.swing.*;
import java.awt.*;

public class MyGUI extends JFrame {

    private final int WIDTH = 400;
    private final int HEIGHT = 400;

    public MyGUI(String title) {
        super(title);
        setSize(WIDTH, HEIGHT);
        add(new Board());
        setVisible(true);
        setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
    }

}