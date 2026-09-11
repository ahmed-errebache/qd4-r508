package fr.errebache.springbootdocker;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * Un seul endpoint : il sert de temoin pour verifier que l'application
 * repond, d'abord en local, puis depuis le conteneur Docker.
 */
@RestController
public class GreetingController {

    @GetMapping("/greeting")
    public String greeting() {
        return "Greetings from Docker!";
    }
}
