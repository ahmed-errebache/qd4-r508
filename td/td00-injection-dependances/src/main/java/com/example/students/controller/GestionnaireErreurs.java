package com.example.students.controller;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

/**
 * Traduit les exceptions metier en codes HTTP corrects.
 *
 * Sans ce gestionnaire, toute exception non rattrapee remonte en
 * 500 Internal Server Error. C'est faux : une saisie invalide est une erreur
 * du client, pas une panne du serveur. Le client doit recevoir 400 Bad Request
 * et un message qui lui dit quoi corriger.
 *
 * @RestControllerAdvice s'applique a tous les controleurs du composant scan.
 */
@RestControllerAdvice
public class GestionnaireErreurs {

    @ExceptionHandler(IllegalArgumentException.class)
    public ResponseEntity<String> saisieInvalide(IllegalArgumentException e) {
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(e.getMessage());
    }
}
