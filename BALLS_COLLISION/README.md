# es 012 square animation

Un primo esempio di animazione.

## il disegno

Il metodo
```java
@Override
protected void paintComponent(Graphics g) {
    super.paintComponent(g);
    Graphics2D g2d = (Graphics2D) g;
    g2d.setStroke(new BasicStroke(4));
    g2d.setColor(Color.RED);
    g2d.drawRect(x, y, WIDTH, HEIGHT);
    Toolkit.getDefaultToolkit().sync();
}
```
permette di disegnare un *frame* di animazione, `Graphics2D` [jdoc](https://docs.oracle.com/javase/8/docs/api/java/awt/Graphics2D.html) permette di gestire la geometria degli oggetti, il loro colore, la dimensione delle linee, il *layout* del testo; permette di gestire la grafica 2D.

## animazioni fluide

```java
Toolkit.getDefaultToolkit().sync();
```
`Toolkit` [jdoc](https://docs.oracle.com/javase/8/docs/api/java/awt/Toolkit.html) è una classe astratta, alcune finestre, vedi metodo `sync()` non bufferizzano, tale metodo assicura l'aggiornamento specialmete durante le animazioni.

## il metodo `repaint()`

Il metodo `repaint()` [jdoc](https://docs.oracle.com/javase/8/docs/api/java/awt/Component.html#repaint--) per i componenti leggeri, tipo `swing` richiama `paint`. Non è necessario, come spesso accade nei *canvas*, un operazione di cancellazione del *frame* precedente.

## il metodo `loop()`

Prepara il successivo *frame* dell'animazione, i metodi `getWidth()` e `getHeight()` non ritornano `0` solo dopo la fase di *paint* (aggancio e disegno del `Component`), usarli con cautela!

## materiali

[1] "Drawing Geometric Primitives" [qui](https://docs.oracle.com/javase/tutorial/2d/geometry/primitives.html).  
[2] "Drawing Shapes" [qui](https://docs.oracle.com/javase/tutorial/2d/geometry/arbitrary.html).  