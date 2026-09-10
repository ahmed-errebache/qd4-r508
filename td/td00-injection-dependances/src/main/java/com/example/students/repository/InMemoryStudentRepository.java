package com.example.students.repository;

import java.util.ArrayList;
import java.util.List;

import org.springframework.context.annotation.Primary;
import org.springframework.stereotype.Repository;

/**
 * Implementation retenue par defaut.
 *
 * @Primary designe le bean a injecter quand plusieurs candidats conviennent.
 * L'alternative est @Qualifier("consoleStudentRepository") cote injection,
 * qui nomme explicitement le bean voulu.
 *
 * Avoir deux implementations n'est pas artificiel : c'est exactement ce que
 * l'injection de dependances rend possible. Remplacer le stockage revient a
 * changer une annotation, sans modifier une ligne du service.
 */
@Repository
@Primary
public class InMemoryStudentRepository implements StudentRepository {

    private final List<String> etudiants = new ArrayList<>();

    @Override
    public void save(String name) {
        etudiants.add(name);
    }

    @Override
    public List<String> findAll() {
        return List.copyOf(etudiants);
    }
}
