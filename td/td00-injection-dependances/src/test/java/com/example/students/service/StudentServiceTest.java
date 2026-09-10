package com.example.students.service;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;

import java.util.ArrayList;
import java.util.List;

import org.junit.jupiter.api.Test;

import com.example.students.repository.StudentRepository;

/**
 * La demonstration de l'interet de l'injection de dependances.
 *
 * Ces tests n'ont besoin NI de Spring, NI de base de donnees, NI de serveur.
 * On construit le service a la main en lui passant un faux repository.
 *
 * Avec la version "sans DI" du cours - un `new StudentRepository()` en dur
 * dans le service - ce fichier serait impossible a ecrire : aucun moyen de
 * substituer l'implementation.
 */
class StudentServiceTest {

    /** Faux repository : il memorise ce qu'on lui donne, sans effet de bord. */
    static class FakeStudentRepository implements StudentRepository {
        private final List<String> recus = new ArrayList<>();

        @Override public void save(String name) { recus.add(name); }
        @Override public List<String> findAll()  { return recus; }
    }

    @Test
    void enregistre_un_etudiant() {
        FakeStudentRepository faux = new FakeStudentRepository();
        StudentService service = new StudentService(faux);

        service.saveStudent("Paul");

        assertEquals(List.of("Paul"), faux.findAll());
    }

    @Test
    void supprime_les_espaces_autour_du_nom() {
        FakeStudentRepository faux = new FakeStudentRepository();
        StudentService service = new StudentService(faux);

        service.saveStudent("  Marie  ");

        assertEquals(List.of("Marie"), faux.findAll());
    }

    @Test
    void refuse_un_nom_vide() {
        StudentService service = new StudentService(new FakeStudentRepository());

        assertThrows(IllegalArgumentException.class, () -> service.saveStudent("   "));
    }

    @Test
    void liste_vide_au_depart() {
        StudentService service = new StudentService(new FakeStudentRepository());

        assertTrue(service.listStudents().isEmpty());
    }
}
