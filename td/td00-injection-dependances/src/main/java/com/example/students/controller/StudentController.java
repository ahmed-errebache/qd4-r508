package com.example.students.controller;

import com.example.students.service.StudentService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

/**
 * Point d'entree HTTP du TD0.
 *
 * Le service est injecte par le constructeur : la dependance est obligatoire,
 * le champ peut etre final, et la classe reste testable sans Spring.
 */
@RestController
@RequestMapping("/students")
public class StudentController {

    private final StudentService service;

    public StudentController(StudentService service) {
        this.service = service;
    }

    /**
     * Le nom du parametre est ecrit explicitement : @RequestParam("name").
     * Sans cela, Spring doit le deduire du .class, ce qui suppose que le code
     * a ete compile avec l'option -parameters (voir maven-compiler-plugin
     * dans le pom.xml). Nommer le parametre rend le contrat independant
     * des options de compilation.
     */
    @PostMapping("/add")
    public ResponseEntity<String> addStudent(@RequestParam("name") String name) {
        service.saveStudent(name);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body("Etudiant ajoute avec succes : " + name);
    }

    @GetMapping
    public List<String> listStudents() {
        return service.listStudents();
    }
}
