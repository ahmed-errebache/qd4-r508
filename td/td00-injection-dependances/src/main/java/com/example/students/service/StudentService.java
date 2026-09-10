package com.example.students.service;

import java.util.List;

import org.springframework.stereotype.Service;

import com.example.students.repository.StudentRepository;

/**
 * Logique metier.
 *
 * INJECTION PAR CONSTRUCTEUR - c'est la forme recommandee :
 *   - le champ peut etre final, donc l'objet est immuable apres construction
 *   - impossible d'instancier le service sans sa dependance
 *   - aucun besoin de Spring pour le tester : on passe un faux repository
 *
 * Depuis Spring 4.3, @Autowired est FACULTATIF sur un constructeur unique.
 * Son absence ici n'est pas un oubli.
 */
@Service
public class StudentService {

    private final StudentRepository repository;

    public StudentService(StudentRepository repository) {
        this.repository = repository;
    }

    public void saveStudent(String name) {
        if (name == null || name.isBlank()) {
            throw new IllegalArgumentException("Le nom de l'etudiant est obligatoire");
        }
        repository.save(name.trim());
    }

    public List<String> listStudents() {
        return repository.findAll();
    }
}
