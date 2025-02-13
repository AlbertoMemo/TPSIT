package org.example;

import com.formdev.flatlaf.FlatDarkLaf;
import com.formdev.flatlaf.FlatLaf;

import javax.swing.*;

public class Main {
    public static void main(String[] args) {
        FlatLaf.setup(new FlatDarkLaf());
        SwingUtilities.invokeLater(()-> new MyGUI("es012 square animation"));
    }
}