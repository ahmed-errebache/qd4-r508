package com.example.students;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

/**
 * Point d'entree de l'application.
 *
 * @SpringBootApplication regroupe trois annotations :
 *   - @Configuration        : la classe peut declarer des beans
 *   - @EnableAutoConfiguration : Spring configure ce qu'il trouve dans le classpath
 *   - @ComponentScan        : Spring scanne CE package et ses sous-packages
 *
 * C'est le @ComponentScan qui fait tout le travail ici : il decouvre
 * @RestController, @Service et @Repository sous com.example.students.
 * Une classe placee en dehors de ce package ne serait jamais detectee.
 */
@SpringBootApplication
public class StudentsApplication {

    public static void main(String[] args) {
        SpringApplication.run(StudentsApplication.class, args);
    }
}
