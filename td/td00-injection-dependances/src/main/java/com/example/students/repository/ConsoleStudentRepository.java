package com.example.students.repository;

import java.util.ArrayList;
import java.util.List;

import org.springframework.stereotype.Repository;

/**
 * Implementation minimale du support de cours : elle se contente d'afficher.
 *
 * @Repository est une specialisation de @Component. Fonctionnellement elle
 * cree un bean de la meme maniere, mais elle exprime le role de la classe et
 * active la traduction des exceptions d'acces aux donnees.
 *
 * Deux implementations de StudentRepository coexistent dans ce projet.
 * Sans arbitrage, Spring refuserait de demarrer :
 *   NoUniqueBeanDefinitionException: expected single matching bean but found 2
 * C'est @Primary, sur l'autre implementation, qui designe celle par defaut.
 */
@Repository
public class ConsoleStudentRepository implements StudentRepository {

    private final List<String> etudiants = new ArrayList<>();

    @Override
    public void save(String name) {
        etudiants.add(name);
        System.out.println("Etudiant enregistre : " + name);
    }

    @Override
    public List<String> findAll() {
        return List.copyOf(etudiants);
    }
}
