package com.example.students.repository;

import java.util.List;

/**
 * Le contrat d'acces aux donnees.
 *
 * C'est de CETTE interface que le service depend, jamais d'une classe concrete.
 * C'est ce qui rend l'implementation interchangeable : base de donnees en
 * production, objet factice dans les tests, sans toucher au service.
 */
public interface StudentRepository {

    void save(String name);

    List<String> findAll();
}
