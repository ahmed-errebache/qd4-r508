package com.example.students.controller;

import java.util.List;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.example.students.service.StudentService;

/**
 * Couche web.
 *
 * @RestController = @Controller + @ResponseBody : les valeurs retournees sont
 * serialisees dans le corps de la reponse, il n'y a pas de vue a resoudre.
 *
 * Le controleur ne connait que le service. Il ignore totalement l'existence
 * du repository : c'est la separation des couches.
 */
@RestController
@RequestMapping("/students")
public class StudentController {

    private final StudentService service;

    public StudentController(StudentService service) {
        this.service = service;
    }

    @PostMapping("/add")
    public ResponseEntity<String> addStudent(@RequestParam String name) {
        service.saveStudent(name);
        return ResponseEntity.status(HttpStatus.CREATED)
                             .body("Etudiant ajoute avec succes : " + name);
    }

    @GetMapping
    public List<String> listStudents() {
        return service.listStudents();
    }
}
