package io.echo.core;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.ComponentScan;

@SpringBootApplication
@ComponentScan(basePackages = {"io.echo.core"})
public class EchoCoreApplication {

    public static void main(String[] args) {
        SpringApplication.run(EchoCoreApplication.class, args);
        System.out.println("""
                
                🚀 ECHO Core Memory Engine Started
                ===================================
                Local-first • Privacy-first • Automatic
                
                The unpopular truth: People don't need more tools.
                They need a system that captures for them.
                """);
    }
}