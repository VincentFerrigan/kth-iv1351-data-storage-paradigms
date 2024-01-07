package se.kth.iv1351.startup;

import java.util.Properties;

/**
 * Contains the <code>main</code> method. Performs all startup
 * of the application.
 * Properties set up base on:
 * <a href=https://docs.oracle.com/javase/tutorial/essential/environment/sysprop.html>The Java™ Tutorials - System Properties</a>.
 * If you're having trouble loading the resource file <code>config.properties></code>,
 * first check that <code>src/main/resources</code>
 * is correctly configured as a resources directory in your IDE.
 */
public class main {
    /**
     * Starts the application
     *
     * @param args The application does not take any command line parameters
     *
     */
    public static void main(String[] args) {
        Properties properties = new Properties(System.getProperties());
        System.out.println("Hello world!");
    }
}
